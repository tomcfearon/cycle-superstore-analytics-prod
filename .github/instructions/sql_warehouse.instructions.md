# SQL And Warehouse Instructions

## Scope
Use this instruction file for all changes in `css-dwh-project/` and for warehouse-supporting work in `data_platform/`.

## Core Rules
* Maintain strict medallion layering: staging (`stg`) -> intermediate (`int`) -> marts (`marts`).
* Use explicit column lists in views and `INSERT` statements. Never use `SELECT *`.
* **Never join directly to `raw_*` tables.** All joins must be to `stg`, `int`, or `marts` layer views/tables. Raw tables are the unprocessed landing zone and must only be read by staging views.
* Keep one SQL object per file.
* Apply standard naming prefixes: `vw_stg_`, `vw_int_`, `vw_dim_`, `vw_fct_`.
* Keep reusable business logic in `int`; keep marts focused on presentation-ready outputs.
* **Never add business logic to mart views.** Joins, string transformations, derivations, and conditional logic belong in the `int` layer (e.g. `vw_int_*`). Mart views (`03_marts/`) must only do type casting (`CAST`/`TRY_CAST`), column aliasing, and `fn_TitleCase` formatting — they are thin pass-throughs over an `int` source. If logic creep is discovered in a mart view, move it upstream.
* In `int`, use `LOWER()` for robust source string comparisons when classification logic depends on text values.
* In semantic-facing names, preserve acronym casing (`ID`, `VAT`, `URL`) and do not title-case acronyms.

## Schema Map
### Warehouse Layers
* `stg`: staging views over landed/raw data.
* `int`: core business logic and conformed transformations.
* `marts`: physical dimensional/fact tables and mart-facing views.
* `meta`: operational metadata (refresh tracking and control).

### Raw Source Schemas
* `raw_ccdata`: primary ERP landing schema (main ERP source system).
* `raw_css2`: website/ecommerce source landing schema.
* `raw_google`: Google Ads and related marketing source landing schema.
* `raw_365`: Microsoft 365/email source landing schema.

## Stored Procedure Standards
* **Headers:** Every procedure must start with `SET NOCOUNT ON;` and `SET XACT_ABORT ON;`.
* **No `SELECT INTO`:** Never use `IF OBJECT_ID(...) IS NULL SELECT TOP (0) ... INTO`. Target tables exist permanently in `tables/`.
* **Transaction Wrapping:** Wrap all data operations (`TRUNCATE` + `INSERT` + `MERGE`) in `BEGIN TRY ... BEGIN TRANSACTION ... COMMIT TRANSACTION ... END TRY`.
* **Catch & Rollback:** In `BEGIN CATCH`, include `IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;` and end with `THROW 50000, @error_message, 1;`.
* **Metadata Telemetry:** Always calculate execution time in milliseconds and maintain the `MERGE INTO [meta].[refresh_metadata]` block.

## ERP Reverse-Engineering Context
* Main ERP behavior maps to `raw_ccdata`.
* Recovered C# source can be used when business logic needs confirmation and SQL lineage alone is insufficient.
* Source-ERP recovered trees are reference-only and must not be treated as deployable warehouse code.

## Performance: Raw Table Indexing
* `raw_*` tables are heaps by design (fast ADF bulk loads, no clustered key to maintain) — but a heap can and should still carry **nonclustered** indexes on columns that `stg`/`int` views repeatedly join or filter on (e.g. `InvoiceNo`, `FaultNo`, `StockCode`, `CustomerCode`, `OrderNo`). Heap-vs-clustered is about the *clustered* index only; nonclustered indexes don't change bulk-load behavior.
* Before this was addressed once, every `raw_ccdata` table was a zero-index heap, and a single unindexed multi-way join chain (e.g. `int.int_order_credits`, `int.int_dim_transaction` both anti-joining `int.base_repair_headers`) took 13-14 minutes and 15M+ logical reads. Adding targeted nonclustered indexes on the actual join columns cut that to ~1 minute. When a mart load is unexpectedly slow, check first whether its `int`-layer source view joins across large raw/staging tables with no supporting index — this is a much more common cause than the target table's own size.
* Indexes belong in the table DDL file in `tables/`, never in a manual migration script (see Deployment Preference section above) — this applies to raw tables exactly the same as marts tables.
* A join wrapped in `LOWER()`/`TRIM()`/other functions on both sides (e.g. brand matching in `product_consolidated_enriched`) is never sargable — an index on the raw column will not be used no matter what. That needs a persisted computed column or upstream data normalization instead.
* Azure SQL Database has an "Automatic tuning" `CREATE_INDEX` feature but it does not create indexes proactively in real time and is off by default (verify with `sys.database_automatic_tuning_options`) — don't rely on it; missing indexes must be added deliberately.
* Prefer translating confirmed ERP behavior into warehouse SQL; do not copy implementation details blindly.

## Raw Source Table Rule
* **Never rename any raw source table or its columns** (in any `raw_*` schema). Column names must exactly match what the source system / ADF pipeline delivers — any rename breaks ingestion.
* This applies to all `raw_*` schemas: `raw_ccdata`, `raw_css2`, `raw_google`, `raw_365`, etc.
* The `stg` layer is where source column names are aliased to domain names (e.g. `inv.[stock_key] AS [product_key]`). Only rename at `stg` and above.

## Product Key Domain Rule
* Preserve ERP product key normalization patterns (the key was historically called `stock_key` — prefer `product_key` for all new and renamed objects):
	1. `<modelno>-1` for bike model keys.
	2. `<stockcode>-0` for non-bike/sundry keys.
	3. `<code>-3` reserved hard-coded placeholders.
* Keep product-key normalization logic centralized and reusable in `int`.

## Folder Placement
* Warehouse DDL and DML objects go in `css-dwh-project/` in the correct object folder.
* Warehouse operational SQL (reload/orchestration/ops) goes in `data_platform/ops/`.
* Security and environment administration scripts go in `data_platform/admin/`; exceptional manual data or schema migrations go in `data_platform/scripts/maintenance/`.
* Validation and investigation SQL created during debugging goes in `ad_hoc/sql/`.

## Folder Placement and Schema Alignment
* Table DDL files must strictly match their containing folder schema:
  * `tables/00_meta/*` $\rightarrow$ `CREATE TABLE [meta].[table_name]`
  * `tables/01_bronze/365/*` $\rightarrow$ `CREATE TABLE [raw_365].[table_name]`
  * `tables/01_bronze/ccdata/*` $\rightarrow$ `CREATE TABLE [raw_ccdata].[table_name]`
  * `tables/01_bronze/css2/*` $\rightarrow$ `CREATE TABLE [raw_css2].[table_name]`
  * `tables/01_bronze/google/*` $\rightarrow$ `CREATE TABLE [raw_google].[table_name]`
  * `tables/02_intermediate/*` $\rightarrow$ `CREATE TABLE [int].[table_name]`
  * `tables/03_gold/*` $\rightarrow$ `CREATE TABLE [marts].[table_name]`
* Views follow the same layer boundaries:
  * `views/01_staging/*` $\rightarrow$ `CREATE VIEW [stg].[vw_stg_*]`
  * `views/02_intermediate/*` $\rightarrow$ `CREATE VIEW [int].[vw_int_*]`
  * `views/03_marts/*` $\rightarrow$ `CREATE VIEW [marts].[vw_dim_*]` or `[marts].[vw_fct_*]`
  * `views/04_semantic/*` $\rightarrow$ `CREATE VIEW [dbo].[NN - Friendly Name]`
* Warehouse operational SQL (reload/orchestration/ops) goes in `data_platform/ops/`.
* Security and environment administration scripts go in `data_platform/admin/`; exceptional manual data or schema migrations go in `data_platform/scripts/maintenance/`.
* Validation and investigation SQL created during debugging goes in `ad_hoc/sql/`.


## Deployment And Safety
* Treat `css-dwh-project/` as the deployment source of truth.
* **Test fixture schema validation is source-first.** Before changing or running database test fixtures, validate their literal values, types, and column widths against the canonical DDL in `css-dwh-project/tables/`; do not query `css-dwh-test` merely to rediscover schema already defined by the DACPAC. Query the test database only to validate runtime behavior or diagnose confirmed deployment drift.
* **Environment separation is mandatory.** Destructive integration tests (reset, seed, load, and assertions) run only against disposable `css-dwh-test`; never run them against `css-dwh-dev`. Use `css-dwh-dev` only for non-destructive development validation.
* Avoid unrelated formatting churn in SQL files.
* Preserve compatibility with existing schema and downstream semantic model dependencies.
* **Do not use manual migration scripts as the authoritative source for current schema definition.** When diagnosing schema drift, deployment failures, or current object shape, check the SQL project DDL in `css-dwh-project/`, the live object definition if the user asked for execution, deploy workflows, and source/ERP references first. Only consult `data_platform/scripts/maintenance/` when explicitly asked or when confirming migration history, one-off data moves, renames, or destructive change sequencing.
* **Manual migration scripts must be idempotent and use GO batch separators.** Wrap every `ALTER TABLE ... ADD` in `IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'schema.table') AND name = N'column')` and every `ALTER TABLE ... DROP COLUMN` in `IF EXISTS (...)`. Place a `GO` after each statement. This makes scripts safe to re-run and prevents "column already exists" errors in SSMS / Azure Data Studio.
* **Column rename = TWO mandatory changes.** When renaming any column on a mart/dim table, you MUST update BOTH: (1) the table DDL file in `tables/` (the SQL project source of truth the build validates against), AND (2) create an `sp_rename` script in `data_platform/scripts/maintenance/`. Updating only the migration script will break the build; updating only the DDL file will break the live database on next load. Both are always required together.

## Deployment Preference — DACPAC Over Manual Migration Scripts
* **All schema objects belong in the SQL project files** — this includes tables, views, procedures, functions, AND indexes. The DACPAC publish handles creating these objects in the target database automatically. Never create a manual migration script as a substitute for adding an object to the SQL project.
* **Stored procedure changes always go in the project file** (`css-dwh-project/procedures/`), never as a `CREATE OR ALTER PROCEDURE` in a manual migration script. The project file is deployed via DACPAC.
* **Indexes must be defined in the table DDL file** (e.g. `css-dwh-project/tables/01_source/ccdata/stock.sql`), not in a separate manual migration script. Adding an index to the SQL project is the correct and only path — the DACPAC publish will CREATE the index in dev and prod without any manual script.
* Manual migration scripts in `data_platform/scripts/maintenance/` are only for changes the DACPAC **cannot** express as pure DDL: column renames (`sp_rename`), one-time data migrations, destructive changes (DROP COLUMN while preserving live data), or anything requiring a guaranteed execution order that spans multiple object types.
* Rule of thumb: **schema objects (including indexes) → SQL project; rename / drop / migrate data → manual migration script**.

## Deployment Sequence
1. For additive changes (new columns, new objects): publish DACPAC directly — no manual migration script needed.
2. For rename/drop/data-migration changes: run the manual migration script first, then publish DACPAC.
3. Deploy changed `int` views.
4. Deploy changed `marts` views.
5. Deploy changed semantic views.
6. Deploy changed loader procedures.

## Post-Change Execution Rundown (Required After Every Session)
After completing any set of SQL changes, always provide a concise execution rundown at the end of the response using the following format:

1. **Manual migration scripts** (if any table DDL changed): Link to the file in `data_platform/scripts/maintenance/` and show the exact `ALTER TABLE` statement inline.
2. **Publish prompt** (if views or procedures changed): Tell the user to publish via the SQL project (or list the specific `CREATE OR ALTER` objects if only a few changed).
3. **Loader execution links** (for every mart table touched): Link directly to the corresponding ops file in `data_platform/ops/marts/` so the user can open and run it. Do not just name the file — link it.

If many objects changed, prompt the user to publish all changes rather than listing every file individually. Always include alteration statements inline regardless of how many other changes there are.

## Semantic View Naming Convention
Semantic views (`04_semantic/`) expose a numbered prefix in the `[dbo]` view name. The number bands are:
* **01–40** — Fact tables (e.g. `[03 - Service Invoices]`, `[09 - Service Orders]`)
* **41–60** — Dimension tables (e.g. `[41 - Document Date]`, `[45 - Order Channel]`, `[50 - Service Type]`)
* Always use the format `[NN - Title Case Name]` with a space either side of the dash.
* Check existing semantic view numbers before assigning a new one to avoid collisions. Current highest dim is 50.

## Column Naming and Type Discipline
* Columns with a `_key` suffix **must always be integer** (matching the dimension PK type). Never use `_key` for varchar/string values.
* If a source value is a name/string, suffix it `_name` (e.g. `salesperson_name`), not `_key`.
* When adding a new FK column to a fact table, confirm the source expression resolves to an integer (e.g. via an employee lookup join) before naming it `_key`.
* When a new integer `_employee_key` column is added to replace a string field, explicitly confirm the old string field is either dropped or renamed to `_name` — do not leave misnamed varchar `_key` columns in place.
* **No name/description columns in fact tables.** Facts store integer keys and numeric measures only. If a string value is needed (e.g. a salesperson name), resolve it to a dimension key at the `int` layer via a lookup join — never carry the raw name string into `marts` or semantic views.

## Column Addition Checklist
When adding a new column to any mart fact or dimension table, **all six of the following must be updated together** — never leave any one of them out:
1. **Table DDL** — `css-dwh-project/tables/` (the SQL project source of truth).
2. **Loader procedure** — `css-dwh-project/procedures/load/mart/` — add to both the `INSERT` column list and the `SELECT` column list.
3. **Mart view** — `css-dwh-project/views/03_marts/` — pass the column through.
4. **Semantic view** — `css-dwh-project/views/04_semantic/` — expose with a friendly alias.
5. **Manual migration script** — `data_platform/scripts/maintenance/` — `ALTER TABLE … ADD` wrapped in an `IF NOT EXISTS` guard.
6. **Upstream int/intermediate views** — any `int`-layer view that feeds the mart must also pass the column through.