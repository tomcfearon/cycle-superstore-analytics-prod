# Warehouse Database Tests

This harness validates the deployed warehouse against the disposable Azure SQL database `css-dwh-test`. It uses deterministic synthetic raw data and never copies production rows.

## Test Structure

- `reset_test_database.sql` clears only the disposable test database before every run.
- `seeds/` holds deterministic raw-source inputs. `seed_test_data.sql` is the suite entry point; add shared records before pipeline-specific rows as coverage grows.
- `assertions/invariants/` contains reusable warehouse-wide grain and data-quality rules.
- `assertions/contracts/` verifies exact expected results for each synthetic business-flow fixture.
- `assertions/core.sql` is the deterministic pull-request suite, combining all current invariants and contracts.
- `run_assertions.sql` is the stable `sqlcmd` assertion entry point; it delegates to the core suite.
- `run_database_tests.ps1` is the local orchestrator. The GitHub workflow repeats the same build, publish, reset, seed, load, and assertion sequence.

## Test Contract

Each run performs the following operations in order:

1. Build and optionally publish the canonical SQL project.
2. Verify the connection targets `css-dwh-test` and the full-load procedure exists.
3. Truncate loader-managed raw, intermediate, and mart tables.
4. Preserve the DACPAC-seeded `raw_ccdata.Category_Map` and `marts.dim_order_channel` reference tables.
5. Seed exactly one deterministic raw record per raw-source table through the modular domain fixtures.
6. Run `dbo.usp_load_warehouse_full` through the existing ops script.
7. Run foundational warehouse invariants and fixture-specific integration contracts.

The fixture must produce customer `TEST-CUST-1`, employee `900001`, product `MISC-3`, transaction `ORD-INV-TST-INV-1`, and exactly one matching order-invoice fact row.

## One-Time Identity Bootstrap

An Entra/database administrator must run [data_platform/admin/css_dwh_test_grant_github_actions.sql](../admin/css_dwh_test_grant_github_actions.sql) manually against `css-dwh-test` before the first GitHub Actions publish. The script refuses to run against any other database.

## Local Execution

Prerequisites:

- `dotnet`
- `sqlpackage`
- The `Az.Accounts` PowerShell module for browser-based Microsoft Entra authentication: `Install-Module Az.Accounts -Scope CurrentUser`
- Database deployment rights on `css-dwh-test`

Run the VS Code task `database tests: run css-dwh-test`, or execute:

```powershell
.\data_platform\tests\run_database_tests.ps1 `
    -ServerName 'css-sql-prd-neu.database.windows.net' `
    -ResetConfirmation 'RESET css-dwh-test' `
    -Publish
```

Omit `-Publish` only when the current DACPAC is already deployed. The runner opens a browser for interactive Entra authentication and stores no credentials.

## GitHub Actions

The `Test CSS DWH Database` workflow runs on pull requests to `main` that modify warehouse or test inputs. It can also be manually triggered, which requires selecting `RESET css-dwh-test`. It reuses:

- Existing OIDC secrets `AZURE_CLIENT_ID` and `AZURE_TENANT_ID`.
- The verified server `css-sql-prd-neu.database.windows.net` with the fixed database `css-dwh-test`.

The workflow serializes runs against the shared database and uploads its SQL console log whether the run succeeds or fails.

### Required GitHub Settings

Workflow files make results visible on a pull request; they do not, by themselves, prevent a merge. In GitHub repository settings, protect `main` and require these status checks:

- `Build warehouse DACPAC` from `Build CSS DWH Project for Pull Requests`.
- `Publish and test warehouse` from `Test CSS DWH Database`.
- `Validate Thin Report Bindings` when the PR changes the Power BI paths covered by that workflow.

Also enable **Require branches to be up to date before merging** and restrict bypass permissions to repository administrators only. A required check failure then blocks a normal merge. Git updates `main` at merge time; workflows triggered by that push run afterward and cannot roll the merge back.

The production warehouse workflow declares the `production` GitHub Environment. Create that environment in repository settings and set **Required reviewers**. This leaves production deployment as a separately authorized post-merge action rather than treating it as the first proof that the change works.

## Adding Coverage

Add synthetic rows at the raw layer, preserve relational keys across headers and details, and add a focused contract under `assertions/contracts/`. Add warehouse-wide grain or data-quality rules under `assertions/invariants/`. Include pull-request-safe checks from `assertions/core.sql`; keep fixture values fixed so repeated runs produce identical results.

Contracts should prove an end-to-end business transformation, such as key resolution, financial calculation, status normalization, or channel classification. Do not add assertions that merely repeat seed-row counts already enforced by the fixtures.

Do not use independent `TOP (N)` production extracts. They are nondeterministic, may expose sensitive data, and commonly break parent-child relationships.
