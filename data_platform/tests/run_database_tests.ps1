[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,

    [ValidateSet('css-dwh-test')]
    [string]$DatabaseName = 'css-dwh-test',

    [Parameter(Mandatory = $true)]
    [string]$ResetConfirmation,

    [switch]$Publish
)

$ErrorActionPreference = 'Stop'
$expectedConfirmation = "RESET $DatabaseName"

if ($DatabaseName -ne 'css-dwh-test') {
    throw 'Database tests may run only against css-dwh-test.'
}

if ($ResetConfirmation -cne $expectedConfirmation) {
    throw "Reset not confirmed. Enter exactly: $expectedConfirmation"
}

$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$projectPath = Join-Path $repositoryRoot 'css-dwh-project\css-dwh-project.sqlproj'
$dacpacPath = Join-Path $repositoryRoot 'css-dwh-project\bin\Release\css-dwh-project.dacpac'
$publishProfilePath = Join-Path $repositoryRoot 'css-dwh-project\test.publish.xml'
$resetPath = Join-Path $repositoryRoot 'data_platform\tests\reset_test_database.sql'
$seedPath = Join-Path $repositoryRoot 'data_platform\tests\seeds\seed_test_data.sql'
$loadPath = Join-Path $repositoryRoot 'data_platform\scripts\runners\orchestration\load_warehouse_full.sql'
$assertionPath = Join-Path $repositoryRoot 'data_platform\tests\run_assertions.sql'

# Use a short-lived Entra access token because local Windows identities may not have a resolvable Entra UPN.
Import-Module Az.Accounts -ErrorAction Stop
$connectionString = "Server=tcp:$ServerName,1433;Initial Catalog=$DatabaseName;Encrypt=True;TrustServerCertificate=False;"

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "$Command failed with exit code $LASTEXITCODE."
    }
}

function ConvertTo-PlainTextToken {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Token
    )

    if ($Token -is [System.Security.SecureString]) {
        $tokenPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Token)
        try {
            return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($tokenPointer)
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($tokenPointer)
        }
    }

    return [string]$Token
}

function Get-DatabaseAccessToken {
    if ($null -eq (Get-AzContext)) {
        Write-Host 'Opening browser for Microsoft Entra sign-in...'
        Connect-AzAccount -ErrorAction Stop | Out-Null
    }

    # Request an Azure SQL data-plane token for the signed-in developer identity.
    $accessToken = Get-AzAccessToken -ResourceUrl 'https://database.windows.net/' -ErrorAction Stop
    return ConvertTo-PlainTextToken -Token $accessToken.Token
}

function Get-SqlCmdScriptText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $scriptDirectory = Split-Path -Parent $Path
    $expandedLines = foreach ($line in Get-Content -LiteralPath $Path) {
        if ($line -match '^\s*:r\s+(.+?)\s*$') {
            $includePath = $Matches[1].Trim().Trim('"')
            $scriptRelativePath = Join-Path $scriptDirectory $includePath
            $repositoryRelativePath = Join-Path $repositoryRoot $includePath

            if (Test-Path -LiteralPath $scriptRelativePath) {
                Get-SqlCmdScriptText -Path $scriptRelativePath
            }
            elseif (Test-Path -LiteralPath $repositoryRelativePath) {
                Get-SqlCmdScriptText -Path $repositoryRelativePath
            }
            else {
                throw "SQLCMD include not found: $includePath in $Path"
            }
        }
        elseif ($line -match '^\s*:ON ERROR EXIT\s*$') {
            continue
        }
        elseif ($line -match '^\s*:') {
            throw "Unsupported SQLCMD directive in ${Path}: $line"
        }
        else {
            $line
        }
    }

    return $expandedLines -join [Environment]::NewLine
}

function Invoke-DatabaseSql {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SqlText,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $connection.AccessToken = $AccessToken

    try {
        $connection.Open()
        foreach ($batch in $SqlText -split '(?im)^\s*GO\s*(?:--.*)?$') {
            if ([string]::IsNullOrWhiteSpace($batch)) {
                continue
            }

            $command = $connection.CreateCommand()
            $command.CommandTimeout = 0
            $command.CommandText = $batch
            [void]$command.ExecuteNonQuery()
        }
    }
    finally {
        $connection.Dispose()
    }
}

function Invoke-TestSqlFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    Invoke-DatabaseSql -SqlText (Get-SqlCmdScriptText -Path $Path) -AccessToken $AccessToken
}

Push-Location $repositoryRoot

try {
    Write-Host 'Authenticating to Azure SQL with Microsoft Entra...'
    $databaseAccessToken = Get-DatabaseAccessToken

    Write-Host 'Building warehouse DACPAC...'
    Invoke-CheckedCommand -Command 'dotnet' -Arguments @('build', $projectPath, '-c', 'Release')

    if ($Publish) {
        Write-Host "Publishing warehouse DACPAC to $DatabaseName..."
        Invoke-CheckedCommand -Command 'sqlpackage' -Arguments @(
            '/Action:Publish',
            "/SourceFile:$dacpacPath",
            "/Profile:$publishProfilePath",
            "/TargetServerName:$ServerName",
            "/TargetDatabaseName:$DatabaseName",
            '/UniversalAuthentication:True'
        )
    }

    Write-Host 'Running test database preflight...'
    Invoke-DatabaseSql -SqlText "SET NOCOUNT ON; IF DB_NAME() <> N'css-dwh-test' THROW 52140, 'Preflight refused: unexpected database.', 1; IF OBJECT_ID(N'dbo.usp_load_warehouse_full', N'P') IS NULL THROW 52141, 'Preflight failed: warehouse DACPAC is not deployed.', 1; SELECT DB_NAME() AS database_name, ORIGINAL_LOGIN() AS original_login;" -AccessToken $databaseAccessToken

    Write-Host 'Resetting loader-managed test data...'
    Invoke-TestSqlFile -Path $resetPath -AccessToken $databaseAccessToken

    Write-Host 'Seeding synthetic raw fixture...'
    Invoke-TestSqlFile -Path $seedPath -AccessToken $databaseAccessToken

    Write-Host 'Running canonical warehouse load...'
    Invoke-TestSqlFile -Path $loadPath -AccessToken $databaseAccessToken

    Write-Host 'Running warehouse assertions...'
    Invoke-TestSqlFile -Path $assertionPath -AccessToken $databaseAccessToken

    Write-Host 'css-dwh-test database tests passed.'
}
finally {
    Pop-Location
}