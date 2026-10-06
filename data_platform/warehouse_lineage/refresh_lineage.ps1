param(
    [string]$FocusKey,
    [int]$FocusDepth = 1
)

$ErrorActionPreference = "Stop"

function PickFirst([string[]]$vals) {
    foreach ($v in $vals) {
        if (-not [string]::IsNullOrWhiteSpace($v)) {
            return $v
        }
    }
    return ""
}

function NodeId([string]$k) {
    return ($k -replace "[^a-zA-Z0-9_]", "_")
}

function StripSqlComments([string]$text) {
    # Comments (e.g. "-- passed through from raw_ccdata.X") contain FROM/JOIN/INSERT-shaped
    # text that the reference regexes would otherwise match as a real dependency, creating
    # phantom edges straight from int/marts views to raw tables. Strip before any matching.
    $noBlock = [regex]::Replace($text, '(?s)/\*.*?\*/', ' ')
    $noLine = [regex]::Replace($noBlock, '--[^\r\n]*', '')
    return $noLine
}

function GetProjectSqlFiles([string]$rootPath, [string]$archivedSegmentPattern) {
    if (-not (Test-Path $rootPath)) {
        throw "Required lineage source folder was not found: $rootPath"
    }

    return @(
        Get-ChildItem -Path $rootPath -Recurse -File -Filter "*.sql" |
        Where-Object { $_.FullName -notmatch $archivedSegmentPattern }
    )
}

function PickObjectName([System.Text.RegularExpressions.Match]$match) {
    return PickFirst @(
        $match.Groups["obj_q"].Value,
        $match.Groups["obj_b"].Value,
        $match.Groups["obj_u"].Value,
        $match.Groups["obj"].Value
    )
}

function GetLayer([string]$schema) {
    $s = $schema.ToLower()
    if ($s -like "raw*") { return "raw" }
    if ($s -eq "stg") { return "staging" }
    if ($s -eq "int") { return "intermediate" }
    if ($s -eq "marts") { return "marts" }
    return "external"
}

function GetViewLayer([string]$filePath, [string]$schema) {
    if ($filePath -match '[\\/]views[\\/]04_semantic[\\/]') { return 'semantic' }
    if ($filePath -match '[\\/]views[\\/]03_gold[\\/]') { return 'marts' }
    return GetLayer $schema
}

function GetNodeLabel([object]$node) {
    if ($node.layer -eq "semantic") {
        if ($node.PSObject.Properties["display_obj"] -and -not [string]::IsNullOrWhiteSpace($node.display_obj)) {
            return $node.display_obj
        }

        return $node.obj
    }

    return $node.key
}

function GetMermaidLayerClass([string]$layer) {
    switch ($layer) {
        "raw" { return "bronze" }
        "staging" { return "silver" }
        "intermediate" { return "intermediate" }
        "marts" { return "gold" }
        "semantic" { return "semantic" }
        default { return "external" }
    }
}

function GetGraphHeaderHtml([hashtable]$rawSchemaLabels, [hashtable]$rawSchemaColors) {
    $sourceRows = @()
    foreach ($schema in ($rawSchemaLabels.Keys | Sort-Object)) {
        $color = if ($rawSchemaColors.ContainsKey($schema)) { $rawSchemaColors[$schema] } else { "#dbeafe" }
        $label = $rawSchemaLabels[$schema]
        $sourceRows += ('          <TR><TD WIDTH="18" HEIGHT="18" BGCOLOR="' + $color + '"></TD><TD ALIGN="LEFT">' + $label + '</TD></TR>')
    }

    $header = @(
        '<TABLE BORDER="0" CELLBORDER="0" CELLSPACING="16" CELLPADDING="0">',
        '  <TR>',
        '    <TD COLSPAN="2" ALIGN="CENTER"><FONT POINT-SIZE="26"><B>Cycle Superstore Data Warehouse Lineage</B></FONT></TD>',
        '  </TR>',
        '  <TR>',
        '    <TD ALIGN="CENTER" VALIGN="TOP">',
        '      <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="8" COLOR="#94a3b8">',
        '        <TR><TD BGCOLOR="#e2e8f0" ALIGN="CENTER"><B>Node Types</B></TD></TR>',
        '        <TR><TD BGCOLOR="#ffffff" ALIGN="LEFT">Square box = table<BR ALIGN="LEFT"/>Rounded box = view<BR ALIGN="LEFT"/>Edge color = originating object</TD></TR>',
        '      </TABLE>',
        '    </TD>',
        '    <TD ALIGN="CENTER" VALIGN="TOP">',
        '      <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="8" COLOR="#94a3b8">',
        '        <TR><TD BGCOLOR="#e2e8f0" ALIGN="CENTER"><B>Bronze Sources</B></TD></TR>',
        '        <TR><TD BGCOLOR="#ffffff" ALIGN="LEFT">',
        '          <TABLE BORDER="0" CELLBORDER="0" CELLSPACING="0" CELLPADDING="2">',
        ($sourceRows -join "`n"),
        '          </TABLE>',
        '        </TD></TR>',
        '      </TABLE>',
        '    </TD>',
        '  </TR>',
        '  <TR>',
        '    <TD COLSPAN="2" ALIGN="LEFT">',
        '      <TABLE BORDER="0" CELLBORDER="0" CELLSPACING="2" CELLPADDING="3">',
        '        <TR><TD ALIGN="LEFT"><B>How to read this lineage</B></TD></TR>',
        '        <TR><TD ALIGN="LEFT">This map shows how source data enters the Microsoft Fabric model at Bronze, is shaped through Silver and Intermediate, consolidated in Gold, and exposed through the Semantic layer.</TD></TR>',
        '        <TR><TD ALIGN="LEFT">Each node is a warehouse table or view. Arrows point from an object to its upstream dependencies, so read the diagram right to left.</TD></TR>',
        '        <TR><TD ALIGN="LEFT">Example layer path: read right to left</TD></TR>',
        '        <TR>',
        '          <TD ALIGN="LEFT">',
        '            <TABLE BORDER="0" CELLBORDER="0" CELLSPACING="4" CELLPADDING="5">',
        '              <TR>',
        '                <TD BGCOLOR="#eff6ff">Semantic</TD><TD><FONT POINT-SIZE="15">&#8592;</FONT></TD>',
        '                <TD BGCOLOR="#fef2f2">Gold</TD><TD><FONT POINT-SIZE="15">&#8592;</FONT></TD>',
        '                <TD BGCOLOR="#fffbeb">Intermediate</TD><TD><FONT POINT-SIZE="15">&#8592;</FONT></TD>',
        '                <TD BGCOLOR="#f0fdf4">Silver</TD><TD><FONT POINT-SIZE="15">&#8592;</FONT></TD>',
        '                <TD BGCOLOR="#e2e8f0">Bronze</TD>',
        '              </TR>',
        '            </TABLE>',
        '          </TD>',
        '        </TR>',
        '      </TABLE>',
        '    </TD>',
        '  </TR>',
        '</TABLE>'
    )

    return '<' + ($header -join "`n") + '>'
}

function GetOverviewEdgeAttributes([object]$edge, [hashtable]$edgeOrderByPair, [hashtable]$outgoingCountBySource) {
    $palette = @(
        '#1f77b4', '#2f855a', '#8c564b', '#9467bd', '#b45309', '#6b7280'
    )

    $sourceKey = [string]$edge.from
    if (-not $outgoingCountBySource.ContainsKey($sourceKey) -or [int]$outgoingCountBySource[$sourceKey] -le 1) {
        return 'color="#000000", fontcolor="#000000", penwidth=1.55'
    }

    $pairKey = "$($edge.from)|$($edge.to)"
    $edgeIndex = if ($edgeOrderByPair.ContainsKey($pairKey)) { [int]$edgeOrderByPair[$pairKey] } else { 0 }
    $color = $palette[($edgeIndex % $palette.Count)]
    return 'color="' + $color + '", fontcolor="' + $color + '", penwidth=1.55'
}

function GetFocusNeighborhood([string]$focusKey, [object[]]$allEdges, [int]$maxDepth) {
    $focusNodes = New-Object 'System.Collections.Generic.HashSet[string]'
    if ([string]::IsNullOrWhiteSpace($focusKey)) {
        return $focusNodes
    }

    $outgoing = @{}
    $incoming = @{}
    foreach ($edge in $allEdges) {
        if (-not $outgoing.ContainsKey($edge.from)) {
            $outgoing[$edge.from] = New-Object 'System.Collections.Generic.List[string]'
        }
        if (-not $incoming.ContainsKey($edge.to)) {
            $incoming[$edge.to] = New-Object 'System.Collections.Generic.List[string]'
        }
        $outgoing[$edge.from].Add($edge.to)
        $incoming[$edge.to].Add($edge.from)
    }

    $queue = New-Object 'System.Collections.Generic.Queue[object]'
    $queue.Enqueue([pscustomobject]@{ key = $focusKey; depth = 0 })

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        if (-not $focusNodes.Add($current.key)) {
            continue
        }

        if ($current.depth -ge $maxDepth) {
            continue
        }

        foreach ($neighborMap in @($outgoing, $incoming)) {
            if ($neighborMap.ContainsKey($current.key)) {
                foreach ($neighbor in $neighborMap[$current.key]) {
                    if (-not $focusNodes.Contains($neighbor)) {
                        $queue.Enqueue([pscustomobject]@{ key = $neighbor; depth = $current.depth + 1 })
                    }
                }
            }
        }
    }

    return $focusNodes
}

function BuildFocusDot([string]$title, [string]$focusKey, [object[]]$graphNodes, [object[]]$graphEdges) {
    $focusDependencyNodes = New-Object 'System.Collections.Generic.HashSet[string]'
    $focusConsumerNodes = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($edge in $graphEdges) {
        if ($edge.from -eq $focusKey) {
            [void]$focusDependencyNodes.Add($edge.to)
        }
        elseif ($edge.to -eq $focusKey) {
            [void]$focusConsumerNodes.Add($edge.from)
        }
    }

    $selectedFill = '#fde68a'
    $selectedStroke = '#b45309'
    $dependencyFill = '#dbeafe'
    $dependencyStroke = '#2563eb'
    $consumerFill = '#fee2e2'
    $consumerStroke = '#dc2626'
    $defaultFill = '#f8fafc'
    $defaultStroke = '#64748b'

    $lines = @()
    $lines += "digraph focus_lineage {"
    $lines += "  rankdir=RL;"
    $lines += "  graph [pad=""0.45"", nodesep=""0.7"", ranksep=""1.5"", splines=ortho, concentrate=true, fontname=""Segoe UI"", labelloc=""t"", labeljust=""c"", label=<<TABLE BORDER=""0"" CELLBORDER=""0"" CELLSPACING=""12"" CELLPADDING=""0""><TR><TD COLSPAN=""3"" ALIGN=""CENTER""><FONT POINT-SIZE=""24""><B>$title</B></FONT></TD></TR><TR><TD><FONT COLOR=""$selectedStroke"">■</FONT> Selected object</TD><TD><FONT COLOR=""$dependencyStroke"">■</FONT> Dependency</TD><TD><FONT COLOR=""$consumerStroke"">■</FONT> Downstream consumer</TD></TR></TABLE>>];"
    $lines += "  node [fontsize=15, fontname=""Segoe UI"", color=""#334155"", penwidth=1.35, margin=""0.18,0.12""];"
    $lines += "  edge [color=""#64748b"", arrowsize=0.8, penwidth=1.2];"
    $lines += ""

    $focusRawNodes = @($graphNodes | Where-Object { $_.layer -eq "raw" } | Sort-Object key)
    $focusStgNodes = @($graphNodes | Where-Object { $_.layer -eq "staging" } | Sort-Object key)
    $focusIntNodes = @($graphNodes | Where-Object { $_.layer -eq "intermediate" } | Sort-Object key)
    $focusGoldNodes = @($graphNodes | Where-Object { $_.layer -eq "marts" } | Sort-Object key)
    $focusSemanticNodes = @($graphNodes | Where-Object { $_.layer -eq "semantic" } | Sort-Object key)

    foreach ($node in @($focusRawNodes + $focusStgNodes + $focusIntNodes + $focusGoldNodes + $focusSemanticNodes)) {
        $nodeId = NodeId $node.key
        $label = GetNodeLabel $node
        $shapeStyle = if ($node.node_type -eq 'table') { 'filled' } else { 'rounded,filled' }

        $fillColor = $defaultFill
        $strokeColor = $defaultStroke
        $penWidth = '1.35'

        if ($node.key -eq $focusKey) {
            $fillColor = $selectedFill
            $strokeColor = $selectedStroke
            $penWidth = '2.2'
        }
        elseif ($focusDependencyNodes.Contains($node.key)) {
            $fillColor = $dependencyFill
            $strokeColor = $dependencyStroke
            $penWidth = '1.9'
        }
        elseif ($focusConsumerNodes.Contains($node.key)) {
            $fillColor = $consumerFill
            $strokeColor = $consumerStroke
            $penWidth = '1.9'
        }

        $lines += "    $nodeId [label=""$label"", shape=box, style=""$shapeStyle"", fillcolor=""$fillColor"", color=""$strokeColor"", penwidth=$penWidth];"
    }

    $lines += ""
    foreach ($edge in ($graphEdges | Sort-Object from, to)) {
        $edgeColor = '#94a3b8'
        $edgePenWidth = '1.3'
        if ($edge.from -eq $focusKey) {
            $edgeColor = $dependencyStroke
            $edgePenWidth = '2.2'
        }
        elseif ($edge.to -eq $focusKey) {
            $edgeColor = $consumerStroke
            $edgePenWidth = '2.2'
        }

        $lines += "  $(NodeId $edge.from) -> $(NodeId $edge.to) [color=""$edgeColor"", penwidth=$edgePenWidth];"
    }
    $lines += "}"

    return $lines
}

function GetIntermediateColumnMap([object[]]$nodes, [object[]]$edges, [int]$maxColumns) {
    $intKeys = @($nodes | Where-Object { $_.layer -eq "intermediate" } | Select-Object -ExpandProperty key)
    $levels = @{}
    if ($intKeys.Count -eq 0) {
        return $levels
    }

    $intSet = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($k in $intKeys) {
        [void]$intSet.Add($k)
    }

    $incoming = @{}
    $outgoing = @{}
    foreach ($k in $intKeys) {
        $incoming[$k] = New-Object 'System.Collections.Generic.List[string]'
        $outgoing[$k] = New-Object 'System.Collections.Generic.List[string]'
        $levels[$k] = 0
    }

    foreach ($e in $edges) {
        if ($intSet.Contains($e.from) -and $intSet.Contains($e.to)) {
            $outgoing[$e.from].Add($e.to)
            $incoming[$e.to].Add($e.from)
        }
    }

    # Edge direction is downstream -> dependency. A dependency referenced by another int
    # gets a higher column index (placed one step closer to staging).
    $inDegree = @{}
    foreach ($k in $intKeys) {
        $inDegree[$k] = $incoming[$k].Count
    }

    $q = New-Object 'System.Collections.Generic.Queue[string]'
    foreach ($k in ($intKeys | Sort-Object)) {
        if ($inDegree[$k] -eq 0) {
            $q.Enqueue($k)
        }
    }

    $processed = 0
    while ($q.Count -gt 0) {
        $cur = $q.Dequeue()
        $processed++
        $curLevel = [int]$levels[$cur]
        foreach ($next in $outgoing[$cur]) {
            $nextLevel = $curLevel + 1
            if ([int]$levels[$next] -lt $nextLevel) {
                $levels[$next] = $nextLevel
            }
            $inDegree[$next] = [int]$inDegree[$next] - 1
            if ($inDegree[$next] -eq 0) {
                $q.Enqueue($next)
            }
        }
    }

    # Defensive fallback if a cycle appears unexpectedly.
    if ($processed -lt $intKeys.Count) {
        foreach ($k in $intKeys) {
            if ($incoming[$k].Count -gt 0 -and [int]$levels[$k] -lt 1) {
                $levels[$k] = 1
            }
        }
    }

    $maxIndex = [Math]::Max(0, $maxColumns - 1)
    foreach ($k in $intKeys) {
        $levels[$k] = [Math]::Min([int]$levels[$k], $maxIndex)
    }

    return $levels
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
Set-Location $repoRoot

$viewRoot = Join-Path $repoRoot "css-dwh-project/views"
$tableRoot = Join-Path $repoRoot "css-dwh-project/tables"
$archivedSegmentPattern = '[\\/]+archived[\\/]+'

$viewFiles = GetProjectSqlFiles -rootPath $viewRoot -archivedSegmentPattern $archivedSegmentPattern
$tableFiles = GetProjectSqlFiles -rootPath $tableRoot -archivedSegmentPattern $archivedSegmentPattern
$viewDeclarationPattern = '(?im)^\s*view\s+\[?(?<schema>\w+)\]?\.\s*(?:"(?<obj_q>[^"]+)"|\[(?<obj_b>[^\]]+)\]|(?<obj_u>\w+))'
$createViewDeclarationPattern = '(?is)create\s+(?:or\s+alter\s+)?view\s+\[?(?<schema>\w+)\]?\.\s*(?:"(?<obj_q>[^"]+)"|\[(?<obj_b>[^\]]+)\]|(?<obj_u>\w+))'
$createTableDeclarationPattern = '(?is)create\s+table\s+\[?(?<schema>\w+)\]?\.\s*(?:"(?<obj_q>[^"]+)"|\[(?<obj_b>[^\]]+)\]|(?<obj_u>\w+))'
$insertTargetPattern = '(?is)(?:INSERT\s+INTO|MERGE\s+INTO)\s+\[?(?<schema>\w+)\]?\.\s*(?:"(?<obj_q>[^"]+)"|\[(?<obj_b>[^\]]+)\]|(?<obj_u>\w+))'

$nodes = @()

foreach ($f in $viewFiles) {
    $txt = Get-Content $f.FullName -Raw
    if ([string]::IsNullOrWhiteSpace($txt)) { continue }
    $chunks = [regex]::Split($txt, "(?im)^\s*GO\s*$")
    foreach ($chunk in $chunks) {
        $cleanChunk = StripSqlComments $chunk
        # Match view declarations in both formats used in this repo:
        # 1) CREATE OR ALTER VIEW [schema].[name]
        # 2) CREATE \n -- OR ALTER \n VIEW [schema].[name]
        $m = [regex]::Match($cleanChunk, $viewDeclarationPattern)
        if (-not $m.Success) {
            $m = [regex]::Match($cleanChunk, $createViewDeclarationPattern)
        }
        if ($m.Success) {
            $schema = $m.Groups["schema"].Value.ToLower()
            $displayObj = PickObjectName $m
            $obj = $displayObj.ToLower()
            $nodes += [pscustomobject]@{
                key         = "$schema.$obj"
                schema      = $schema
                obj         = $obj
                display_obj = $displayObj
                layer       = GetViewLayer $f.FullName $schema
                node_type   = "view"
                sql         = $cleanChunk
            }
        }
    }
}

foreach ($f in $tableFiles) {
    $txt = Get-Content $f.FullName -Raw
    $m = [regex]::Match($txt, $createTableDeclarationPattern)
    if ($m.Success) {
        $schema = $m.Groups["schema"].Value.ToLower()
        $displayObj = PickObjectName $m
        $obj = $displayObj.ToLower()
        $nodes += [pscustomobject]@{
            key         = "$schema.$obj"
            schema      = $schema
            obj         = $obj
            display_obj = $displayObj
            layer       = GetLayer $schema
            node_type   = "table"
            sql         = $null
        }
    }
}

$nodes = @($nodes | Sort-Object key, node_type -Unique)
$known = @{}
foreach ($n in $nodes) { $known[$n.key] = $n }

$refPattern = "(?is)\b(?:from|join)\s+(?:(?:\""[^\""]+\""|\[[^\]]+\]|\w+)\s*\.\s*)?(?:\""(?<schema_q>[^\""]+)\""|\[(?<schema_b>[^\]]+)\]|(?<schema_u>\w+))\s*\.\s*(?:\""(?<obj_q>[^\""]+)\""|\[(?<obj_b>[^\]]+)\]|(?<obj_u>\w+))"
$edges = @()

foreach ($d in ($nodes | Where-Object { $_.node_type -eq "view" })) {
    $viewSql = if ($null -eq $d.sql) { "" } else { $d.sql }
    foreach ($mm in [regex]::Matches($viewSql, $refPattern)) {
        $schema = (PickFirst @($mm.Groups["schema_q"].Value, $mm.Groups["schema_b"].Value, $mm.Groups["schema_u"].Value)).ToLower()
        $obj = (PickFirst @($mm.Groups["obj_q"].Value, $mm.Groups["obj_b"].Value, $mm.Groups["obj_u"].Value)).ToLower()
        if (-not $schema -or -not $obj) { continue }

        $to = "$schema.$obj"
        if ($to -eq $d.key) { continue }

        $toLayer = if ($known.ContainsKey($to)) { $known[$to].layer } else { GetLayer $schema }
        if ($toLayer -in @("raw", "staging", "intermediate", "marts", "semantic")) {
            if (-not $known.ContainsKey($to)) {
                $known[$to] = [pscustomobject]@{
                    key         = $to
                    schema      = $schema
                    obj         = $obj
                    display_obj = $obj
                    layer       = $toLayer
                    node_type   = "table"
                    sql         = $null
                }
            }
            $edges += [pscustomobject]@{
                from      = $d.key
                to        = $to
                fromLayer = $d.layer
                toLayer   = $toLayer
            }
        }
    }
}

$edges = @($edges | Sort-Object from, to -Unique)

# Also extract edges from loader procedures (int and marts).
# These procedures INSERT/MERGE INTO a materialised table, reading FROM staging/int/marts views.
# The standard view parser can't see these edges, so we replicate the same FROM/JOIN
# pattern matching against the procedure SQL, treating the INSERT/MERGE INTO target as the
# downstream node (same direction convention as view edges: downstream -> dependency).
# This is evidence-based (only draws an edge when a real loader exists) rather than assumed
# from naming convention - a marts table with no loader (e.g. an orphaned legacy table) must
# not get a fabricated edge to its same-named vw_ view.
foreach ($procRootRelative in @("css-dwh-project/procedures/int", "css-dwh-project/procedures/marts")) {
    $procRoot = Join-Path $repoRoot $procRootRelative
    if (-not (Test-Path $procRoot)) { continue }
    $procFiles = GetProjectSqlFiles -rootPath $procRoot -archivedSegmentPattern $archivedSegmentPattern
    foreach ($f in $procFiles) {
        $txt = Get-Content $f.FullName -Raw
        if ([string]::IsNullOrWhiteSpace($txt)) { continue }
        $txt = StripSqlComments $txt

        # Find the first schema-qualified INSERT INTO â€” that is the materialised target.
        # Temp tables (#Name) won't match because # is not a word char.
        $insMatch = [regex]::Match($txt, $insertTargetPattern)
        if (-not $insMatch.Success) { continue }
        $targetSchema = $insMatch.Groups["schema"].Value.ToLower()
        $targetDisplayObj = PickObjectName $insMatch
        $targetObj = $targetDisplayObj.ToLower()
        $targetKey = "$targetSchema.$targetObj"

        if (-not $known.ContainsKey($targetKey)) {
            $known[$targetKey] = [pscustomobject]@{
                key         = $targetKey
                schema      = $targetSchema
                obj         = $targetObj
                display_obj = $targetDisplayObj
                layer       = GetLayer $targetSchema
                node_type   = "table"
                sql         = $null
            }
        }

        foreach ($mm in [regex]::Matches($txt, $refPattern)) {
            $schema = (PickFirst @($mm.Groups["schema_q"].Value, $mm.Groups["schema_b"].Value, $mm.Groups["schema_u"].Value)).ToLower()
            $obj = (PickFirst @($mm.Groups["obj_q"].Value, $mm.Groups["obj_b"].Value, $mm.Groups["obj_u"].Value)).ToLower()
            if (-not $schema -or -not $obj) { continue }
            $to = "$schema.$obj"
            if ($to -eq $targetKey) { continue }
            $toLayer = if ($known.ContainsKey($to)) { $known[$to].layer } else { GetLayer $schema }
            if ($toLayer -in @("raw", "staging", "intermediate", "marts", "semantic")) {
                if (-not $known.ContainsKey($to)) {
                    $known[$to] = [pscustomobject]@{
                        key         = $to
                        schema      = $schema
                        obj         = $obj
                        display_obj = $obj
                        layer       = $toLayer
                        node_type   = "table"
                        sql         = $null
                    }
                }
                $edges += [pscustomobject]@{
                    from      = $targetKey
                    to        = $to
                    fromLayer = GetLayer $targetSchema
                    toLayer   = $toLayer
                }
            }
        }
    }
}

$edges = @($edges | Sort-Object from, to -Unique)

# Keep only nodes/edges that feed marts tables or semantic views.
$roots = @($known.Values | Where-Object { $_.layer -eq "marts" -and $_.node_type -eq "table" -and ($_.obj -like "dim_*" -or $_.obj -like "fct_*") } | Select-Object -ExpandProperty key)

# Every semantic-layer view is a root: nothing downstream ever depends on a semantic view,
# so gating on "links to a marts table" silently drops views that read straight from stg/int
# (e.g. scaffolded semantic views built ahead of their mart, like [dbo].[10 - Inventory]).
$semanticRoots = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($n in $known.Values) {
    if ($n.layer -eq "semantic") {
        [void]$semanticRoots.Add($n.key)
    }
}

$roots += @($semanticRoots)
$adj = @{}
foreach ($e in $edges) {
    if (-not $adj.ContainsKey($e.from)) { $adj[$e.from] = New-Object System.Collections.Generic.List[string] }
    $adj[$e.from].Add($e.to)
}
$reachable = New-Object 'System.Collections.Generic.HashSet[string]'
$q = New-Object 'System.Collections.Generic.Queue[string]'
foreach ($r in $roots) { $q.Enqueue($r) }
while ($q.Count -gt 0) {
    $cur = $q.Dequeue()
    if (-not $reachable.Add($cur)) { continue }
    if ($adj.ContainsKey($cur)) {
        foreach ($to in $adj[$cur]) {
            if (-not $reachable.Contains($to)) { $q.Enqueue($to) }
        }
    }
}

$hiddenNodeKeys = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($hiddenKey in @('dbo.vw_dim_date_base', 'dbo.vw_ccdata_effective_refresh')) {
    [void]$hiddenNodeKeys.Add($hiddenKey)
}

$visibleKnownNodes = @(
    $known.Values |
    Where-Object { -not $hiddenNodeKeys.Contains($_.key) } |
    Sort-Object key
)
$visibleEdges = @(
    $edges |
    Where-Object {
        -not $hiddenNodeKeys.Contains($_.from) -and
        -not $hiddenNodeKeys.Contains($_.to)
    }
)

$lineageNodes = @(
    $visibleKnownNodes |
    Where-Object { $reachable.Contains($_.key) -and -not $hiddenNodeKeys.Contains($_.key) } |
    Sort-Object key
)
$edges = @(
    $visibleEdges |
    Where-Object {
        $reachable.Contains($_.from) -and
        $reachable.Contains($_.to) -and
        -not $hiddenNodeKeys.Contains($_.from) -and
        -not $hiddenNodeKeys.Contains($_.to)
    }
)

$rawNodes = $lineageNodes | Where-Object { $_.layer -eq "raw" } | Sort-Object key
$stgNodes = $lineageNodes | Where-Object { $_.layer -eq "staging" } | Sort-Object key
$martsNodes = $lineageNodes | Where-Object { $_.layer -eq "marts" } | Sort-Object key
$semanticNodes = $lineageNodes | Where-Object { $_.layer -eq "semantic" } | Sort-Object key

$maxIntermediateColumns = 3
$intColumnByKey = GetIntermediateColumnMap -nodes $lineageNodes -edges $edges -maxColumns $maxIntermediateColumns
$intNodesByColumn = @{}
for ($i = 0; $i -lt $maxIntermediateColumns; $i++) {
    $intNodesByColumn[$i] = @()
}

foreach ($n in ($lineageNodes | Where-Object { $_.layer -eq "intermediate" })) {
    $col = if ($intColumnByKey.ContainsKey($n.key)) { [int]$intColumnByKey[$n.key] } else { 0 }
    $intNodesByColumn[$col] += $n
}
for ($i = 0; $i -lt $maxIntermediateColumns; $i++) {
    $intNodesByColumn[$i] = @($intNodesByColumn[$i] | Sort-Object key)
}

$highestIntColumn = 0
for ($i = $maxIntermediateColumns - 1; $i -ge 0; $i--) {
    if ($intNodesByColumn[$i].Count -gt 0) {
        $highestIntColumn = $i
        break
    }
}

$intColumns = @()
for ($i = $highestIntColumn; $i -ge 0; $i--) {
    $intColumns += $i
}
$intLabelColumn = [int][Math]::Floor($highestIntColumn / 2)

$intNodes = @()
for ($i = 0; $i -le $highestIntColumn; $i++) {
    $intNodes += $intNodesByColumn[$i]
}
$intNodes = @($intNodes | Sort-Object key)

# Color palette for raw source schemas - add new schemas here as sources are added.
$rawSchemaColors = @{
    "raw_ccdata" = "#e2e8f0"   # Slate - ERP (ccdata)
    "raw_css2"   = "#ede9fe"   # Violet - Website (css2)
    "raw_365"    = "#ffedd5"   # Orange - Microsoft 365
    "raw_google" = "#dcfce7"   # Green - Google Ads and Merchant Center
    "raw_payroll" = "#fce7f3" # Rose - Bizimply payroll
    "raw_xero"   = "#dbeafe"   # Blue - Xero accounting
}
$rawSchemaLabels = @{
    "raw_365"    = "Microsoft 365 [Email]"
    "raw_ccdata" = "CCData [Main ERP]"
    "raw_css2"   = "CSS2 [Website data]"
    "raw_google" = "Google Ads + Merchant Center [Advertising and product data]"
    "raw_payroll" = "Bizimply [Payroll timecards]"
    "raw_xero"   = "Xero [Accounting data]"
}
$rawSchemaDefaultColor = "#dbeafe"  # Fallback for any unknown raw schema

function BuildNodeLine($n) {
    $id = NodeId $n.key
    $label = GetNodeLabel $n
    if ($n.layer -eq "raw") {
        $fillColor = if ($rawSchemaColors.ContainsKey($n.schema)) { $rawSchemaColors[$n.schema] } else { $rawSchemaDefaultColor }
    }
    else {
        $fillColor = switch ($n.layer) {
            "staging" { "#f0fdf4" }
            "intermediate" { "#fffbeb" }
            "marts" { "#fef2f2" }
            "semantic" { "#eff6ff" }
            default { "#ffffff" }
        }
    }
    if ($n.node_type -eq "table") {
        return "    $id [label=""$label"", shape=box, style=""filled"", fillcolor=""$fillColor""];"
    }
    return "    $id [label=""$label"", shape=box, style=""rounded,filled"", fillcolor=""$fillColor""];"
}

$dot = @()
$dot += "digraph lineage {"
$dot += "  rankdir=RL;"
$dot += "  graph [pad=""0.9"", nodesep=""1.15"", ranksep=""2.9"", splines=ortho, concentrate=false, fontname=""Segoe UI"", center=true, newrank=true, labelloc=""t"", labeljust=""c"", label=$((GetGraphHeaderHtml -rawSchemaLabels $rawSchemaLabels -rawSchemaColors $rawSchemaColors))];"
$dot += "  node [fontsize=14, fontname=""Segoe UI"", color=""#334155"", penwidth=1.35, margin=""0.16,0.11""];"
$dot += "  edge [color=""#64748b"", arrowsize=0.8, penwidth=1.2];"
$dot += ""
$dot += "  raw_layer [label=""BRONZE LAYER"", shape=plaintext, fontsize=18, fontcolor=""#1d4ed8""];"
$dot += "  stg_layer [label=""SILVER LAYER"", shape=plaintext, fontsize=18, fontcolor=""#166534""];"
$dot += "  int_layer [label=""INTERMEDIATE"", shape=plaintext, fontsize=18, fontcolor=""#92400e""];"
$dot += "  marts_layer [label=""GOLD LAYER"", shape=plaintext, fontsize=18, fontcolor=""#991b1b""];"
$dot += "  semantic_layer [label=""SEMANTIC LAYER"", shape=plaintext, fontsize=18, fontcolor=""#0369a1""];"
$dot += "  raw_anchor [label="""", shape=point, width=0, style=invis];"
$dot += "  stg_anchor [label="""", shape=point, width=0, style=invis];"
foreach ($col in $intColumns) {
    $dot += "  int_anchor_$col [label="""", shape=point, width=0, style=invis];"
}
$dot += "  marts_anchor [label="""", shape=point, width=0, style=invis];"
$dot += "  semantic_anchor [label="""", shape=point, width=0, style=invis];"
$dot += "  raw_anchor -> stg_anchor [style=invis, weight=200, minlen=2];"
if ($intColumns.Count -gt 0) {
    $dot += "  stg_anchor -> int_anchor_$($intColumns[0]) [style=invis, weight=200, minlen=2];"
    for ($idx = 0; $idx -lt $intColumns.Count - 1; $idx++) {
        $fromCol = $intColumns[$idx]
        $toCol = $intColumns[$idx + 1]
        $dot += "  int_anchor_$fromCol -> int_anchor_$toCol [style=invis, weight=200, minlen=2];"
    }
    $dot += "  int_anchor_$($intColumns[$intColumns.Count - 1]) -> marts_anchor [style=invis, weight=200, minlen=2];"
}
else {
    $dot += "  stg_anchor -> marts_anchor [style=invis, weight=200, minlen=2];"
}
$dot += "  marts_anchor -> semantic_anchor [style=invis, weight=200, minlen=2];"
$dot += ""
foreach ($n in $rawNodes) { $dot += BuildNodeLine $n }
foreach ($n in $stgNodes) { $dot += BuildNodeLine $n }
foreach ($n in $intNodes) { $dot += BuildNodeLine $n }
foreach ($n in $martsNodes) { $dot += BuildNodeLine $n }
foreach ($n in $semanticNodes) { $dot += BuildNodeLine $n }
$dot += ""
$outgoingEdgesBySource = @{}
foreach ($edge in $edges) {
    if (-not $outgoingEdgesBySource.ContainsKey($edge.from)) {
        $outgoingEdgesBySource[$edge.from] = New-Object 'System.Collections.Generic.List[object]'
    }
    $outgoingEdgesBySource[$edge.from].Add($edge)
}

$edgeOrderByPair = @{}
$outgoingCountBySource = @{}
foreach ($sourceKey in ($outgoingEdgesBySource.Keys | Sort-Object)) {
    $orderedOutgoingEdges = @($outgoingEdgesBySource[$sourceKey] | Sort-Object to)
    $outgoingCountBySource[$sourceKey] = $orderedOutgoingEdges.Count
    for ($i = 0; $i -lt $orderedOutgoingEdges.Count; $i++) {
        $edgeKey = "$($orderedOutgoingEdges[$i].from)|$($orderedOutgoingEdges[$i].to)"
        $edgeOrderByPair[$edgeKey] = $i
    }
}

$dot += "  { rank=same; raw_layer; raw_anchor;"
foreach ($n in $rawNodes) { $dot += "    $(NodeId $($n.key));" }
$dot += "  }"
$dot += "  { rank=same; stg_layer; stg_anchor;"
foreach ($n in $stgNodes) { $dot += "    $(NodeId $($n.key));" }
$dot += "  }"
foreach ($col in $intColumns) {
    $dot += "  { rank=same;"
    if ($col -eq $intLabelColumn) {
        $dot += "    int_layer;"
    }
    $dot += "    int_anchor_$col;"
    foreach ($n in $intNodesByColumn[$col]) { $dot += "    $(NodeId $($n.key));" }
    $dot += "  }"
}
$dot += "  { rank=same; marts_layer; marts_anchor;"
foreach ($n in $martsNodes) { $dot += "    $(NodeId $($n.key));" }
$dot += "  }"
$dot += "  { rank=same; semantic_layer; semantic_anchor;"
foreach ($n in $semanticNodes) { $dot += "    $(NodeId $($n.key));" }
$dot += "  }"
$dot += ""
foreach ($e in $edges) { $dot += "  $(NodeId $e.from) -> $(NodeId $e.to) [$((GetOverviewEdgeAttributes -edge $e -edgeOrderByPair $edgeOrderByPair -outgoingCountBySource $outgoingCountBySource))];" }
$dot += "}"

$dotPath = "data_platform/warehouse_lineage/lineage_diagram.dot"
Set-Content -Path $dotPath -Value ($dot -join "`n") -Encoding ascii
Write-Host "Updated $dotPath"

if (-not [string]::IsNullOrWhiteSpace($FocusKey)) {
    $normalizedFocusKey = $FocusKey.ToLower()
    $focusNodeKeys = GetFocusNeighborhood -focusKey $normalizedFocusKey -allEdges $visibleEdges -maxDepth $FocusDepth
    if ($focusNodeKeys.Count -gt 0) {
        $focusNodes = @($visibleKnownNodes | Where-Object { $focusNodeKeys.Contains($_.key) } | Sort-Object key)
        $focusEdges = @($visibleEdges | Where-Object { $focusNodeKeys.Contains($_.from) -and $focusNodeKeys.Contains($_.to) } | Sort-Object from, to)
        $focusDot = BuildFocusDot -title ("Focused Lineage: " + $normalizedFocusKey) -focusKey $normalizedFocusKey -graphNodes $focusNodes -graphEdges $focusEdges
        $focusDotPath = "data_platform/warehouse_lineage/lineage_focus.dot"
        Set-Content -Path $focusDotPath -Value ($focusDot -join "`n") -Encoding ascii
        Write-Host "Updated $focusDotPath"
    }
}

# Generate an AI-readable Mermaid lineage context artifact in docs.
$refreshUtc = [DateTime]::UtcNow.ToString("yyyy-MM-dd HH:mm:ss 'UTC'")
$mmd = @()
$mmd += "%% Cycle Superstore warehouse lineage context"
$mmd += "%% Last refresh (UTC): $refreshUtc"
$mmd += "%% Canonical SQL project: css-dwh-project/"
$mmd += "%% Operational support: data_platform/"
$mmd += "%% Edge direction is downstream object -> dependency (right-to-left flow)."
$mmd += "flowchart RL"
$mmd += "  %% Layer class styles: bronze, silver, intermediate, gold, semantic"
$mmd += "  classDef bronze fill:#e2e8f0,stroke:#334155,color:#0f172a;"
$mmd += "  classDef silver fill:#f0fdf4,stroke:#166534,color:#14532d;"
$mmd += "  classDef intermediate fill:#fffbeb,stroke:#92400e,color:#78350f;"
$mmd += "  classDef gold fill:#fef2f2,stroke:#991b1b,color:#7f1d1d;"
$mmd += "  classDef semantic fill:#eff6ff,stroke:#0369a1,color:#0c4a6e;"
$mmd += ""
$mmd += "  %% Context nodes"
$mmd += "  ctx_project[css-dwh-project/: warehouse SQL source of truth]"
$mmd += "  ctx_platform[data_platform/: ADF, admin, ops, scripts, lineage tooling]"
$mmd += "  ctx_docs[docs/warehouse_lineage_context.mmd: AI lineage context artifact]"
$mmd += ""

foreach ($n in $lineageNodes) {
    $id = NodeId $n.key
    $label = GetNodeLabel $n
    $mmd += "  $id[$label]"
}

$mmd += ""
foreach ($e in $edges) {
    $mmd += "  $(NodeId $e.from) --> $(NodeId $e.to)"
}

$mmd += ""
$mmd += "  %% Layer assignments"
foreach ($n in $lineageNodes) { $mmd += "  class $(NodeId $($n.key)) $(GetMermaidLayerClass $n.layer);" }

$mmd += ""
$mmd += "  %% Context linkage"
$mmd += "  ctx_project --> ctx_platform"
$mmd += "  ctx_platform --> ctx_docs"

$mmdPath = "docs/warehouse_lineage_context.mmd"
Set-Content -Path $mmdPath -Value ($mmd -join "`n") -Encoding ascii
Write-Host "Updated $mmdPath"
