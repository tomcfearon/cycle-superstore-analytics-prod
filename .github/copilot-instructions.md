# Cycle Superstore - Global Copilot Instructions

## 1. Communication Notes (Voice-to-Text Overrides)
The primary developer uses voice-to-speech heavily. Expect phonetic transcription errors and informal phrasing.
* **CRITICAL TRANSLATION:** If you hear/read **"auto invoices"** or the **"auto"** prefix in general, it almost always means **"order"** (e.g., `fct_order_invoices`, `int_order_invoices`).
* Interpret ambiguous terms charitably and validate context before assuming a new concept.

## 2. Memory and Instruction Updates
* **"Add to memory" means update `.github` instruction files** — not local/session memory files. When the developer says "add to memory" or "remember this", update the appropriate `.github/instructions/` file (or this global file if the rule is cross-cutting). Only use local `/memories/` files if the developer explicitly says "local memory" or "session memory".
* **ENFORCEMENT:** Never write to `/memories/` in response to an "add to memory" instruction. If you catch yourself about to do that, stop and update the correct `.github/instructions/` file instead.
* When adding a rule, follow the layering in Section 4: cross-cutting rules here, domain-specific rules in the relevant instructions file.

## 3. Standard Fix Response Format
When the developer asks to fix something or asks how to implement a change, always provide all four parts in this order — skip any part that doesn't apply and say so explicitly:
1. **DAX measures** — plain `Measure Name = VAR ... RETURN ...` format only (see Power BI instructions for full format rules).
2. **SQL changes** — show the exact view/table SQL using the `OR ALTER` pattern for any intermediate, mart, or semantic views that need updating.
3. **Publish** — tell the developer to build/publish the SQL project if any `.sql` project files changed, or to run the `OR ALTER` script directly against the dev database.
4. **Execution** — link directly to the existing ops files in `data_platform/ops/marts/` (e.g. [load_fct_service_invoices.sql](data_platform/ops/marts/load_fct_service_invoices.sql)). Do **not** write out `EXEC` statements in a new block — point to the file so the developer can click and run it. **Never skip this step even when SQL changes were made in a prior session** — always list every fact/dim load file that needs to be re-run whenever columns were added, removed, or renamed in the underlying SQL objects. **ENFORCEMENT: Never end a response with "run the loaders" or "run the load files" as plain text without markdown links to the actual files. If you catch yourself about to do that, stop and find the file paths first.**
   * **INT loaders must be listed before mart loaders.** If any intermediate table (e.g. `int.web_product_integrated`) was changed, always include its ops file (e.g. [load_int_web_stock_integrated.sql](data_platform/ops/int/load_int_web_stock_integrated.sql)) first in the execution list, before the mart loader. Never list only the mart loader when an upstream INT table also needs reloading.
   * **Always list every file edited.** At the end of every response that modifies files, include a bulleted list of every file changed with a markdown link to each. Never omit this even for "minor" edits. If you catch yourself closing a response without this list, stop and add it. **Link format — display text MUST exactly match the link target path** (both must be the full workspace-relative path, e.g. `[css-dwh-project/views/03_marts/service/vw_fct_service_invoices.sql](css-dwh-project/views/03_marts/service/vw_fct_service_invoices.sql)`). Never shorten or abbreviate the display text — that breaks the link.

## 4. Global Working Standard
* **Engineer Level:** Operate at senior engineer quality by default: explicit assumptions, low-risk edits, and clear validation steps.
* **Casing:** File names, folder names, and database object names use `snake_case` unless preserving existing external/source-system naming.
* **One Object Per File:** Every SQL script defines or executes exactly one object (one view, one procedure, one table, or one ad-hoc script).
* **Mandatory Inline Comments:** Every changed/added block in T-SQL or YAML includes a short inline comment that explains business logic.
* **No Secrets:** Never commit connection strings, passwords, or tokens.
* **Self-Explanatory Names:** Object names, column names, and measure names must be understandable in isolation — without requiring knowledge of related context. Prefer names like `Floor Bike Build Count` over `Bike Build Floor Count`, and `Product Key` over `Stock Key`. A name should describe *what it is*, not where it fits in a sequence.
* **Fix Upstream:** When a data quality issue can be corrected at an upstream layer (staging → int → mart → semantic), fix it as close to the source as possible. Only compensate downstream when the upstream layer must not be changed (e.g. `stg.*` views that mirror source tables) or when the fix genuinely requires downstream context unavailable upstream.

## 5. Repository Domain Map
* `css-dwh-project/` is the canonical SQL warehouse project.
* `power_bi/` is the canonical Power BI PBIP/TMDL workspace.
* `data_platform/` supports warehouse operations (ADF, admin, ops, scripts, tests, lineage tooling).
* `ad_hoc/sql/` is the default location for validation and diagnostic SQL.
* `docs/` is tracked, curated context (including AI-readable lineage context artifacts).

## 6. Instruction Layering
* Keep this file cross-cutting only.
* SQL/Warehouse policy belongs in `.github/instructions/sql_warehouse.instructions.md`.
* ADF policy belongs in `.github/instructions/adf.instructions.md`.
* Power BI policy belongs in `.github/instructions/power_bi.instructions.md`.
* ERP reverse-engineering policy belongs in `.github/instructions/erp_reference.instructions.md`.
* AI tool permissions (what the AI may do autonomously vs. what needs confirmation) belong in `.github/instructions/ai_tool_permissions.instructions.md`. Read this file before executing any write, delete, or schema-change operation.
* Do not rely on custom repository skills files for policy; maintain policy in instruction files.

## 7. Diagnostic SQL Workflow
* **Never paste diagnostic SQL as a chat code block and ask the developer to run it.** Instead, always try to run it directly via the mssql connection. If the connection is unavailable, create a `.sql` file in `ad_hoc/sql/` (e.g. `diagnose_<topic>.sql`) that the developer can open and execute with one click. Only fall back to showing SQL inline if neither approach is possible.

## 8. Environment and Safety Rules
* **Git Flow:** Default long-lived branches are `dev` and `main`.
* **ADF Dev Policy:** Work in Dev Data Factory only. Keep all triggers stopped in Dev. Do not commit trigger JSON with `runtimeState` set to `Started`.
* **Local Folders:** Keep `.venv/` and `.tmp/` at repo root and ignored as local runtime/scratch folders.
* **Lineage Context — MANDATORY:** Before editing, creating, or advising on any SQL object in the warehouse (`stg`, `int`, `marts`, `dbo` semantic), you MUST read `docs/warehouse_lineage_context.mmd` first to verify the object's type (view vs. physical table), its upstream dependencies, and its downstream consumers. Do not assume from naming conventions alone. This is non-negotiable — skipping it and guessing the architecture is the root cause of cascading errors (e.g. treating a physical table as a view and missing its DDL and load procedure).
* **Power BI MCP Server:** Do not use Power BI MCP tools unless the user explicitly asks for Power BI MCP usage.
* **Execution Gating:** Do not run direct database or cloud-changing commands unless the user explicitly asks for execution.
* **DELETE / DROP / TRUNCATE Rule:** Never execute any DELETE, DROP, or TRUNCATE statement — on any database or environment — without first showing the user the affected rows and receiving an explicit "yes, proceed" confirmation. This is non-negotiable. See `.github/instructions/ai_tool_permissions.instructions.md` for the full permission matrix.
* **SQL Write Operations — Manual Script Rule:** For any SQL write operation other than a SELECT (INSERT, UPDATE, DELETE, DROP, TRUNCATE, ALTER, CREATE), do not execute it directly. Create a reviewed manual script in `data_platform/admin/` for security or environment administration, or `data_platform/scripts/maintenance/` for exceptional data and schema migrations, then show it to the user to run manually. The only exception is explicit one-off meta/diagnostic writes where the user says "run it directly" after seeing the affected rows.

### Error Recognition & Systemic Correction
If we both identify a mistake in your output (the AI's response), evaluate if it is a repeatable error or a one-off anomaly. If it is a repeatable error, suggest a specific text update to prevent it from happening again. In your suggestion, explicitly state whether this new rule should be added to the **global instructions file** or a specific **sectioned instructions file** (and name the exact section).

### Correcting the Developer's Assumptions
When the developer's stated assumption is incorrect or incomplete — and the AI has evidence (e.g. query results, file contents) that disproves it — the AI MUST:
1. State clearly that the assumption is wrong and why.
2. Point the developer to the exact file(s) and line numbers that demonstrate the correct picture (e.g. "See `css-dwh-project/views/03_marts/service/vw_fct_service_invoices.sql` line 44 — the CASE only maps 6 categories, none are combinations").
3. Never silently implement what was asked if doing so would entrench an incorrect mental model. Correct first, then implement.
