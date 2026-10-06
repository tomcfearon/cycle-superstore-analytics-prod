# Power BI Instructions

## Scope
Use this instruction file for all work under `power_bi/`.

---

## Copilot Safety Rules

**These rules are non-negotiable for AI-assisted editing in VS Code.**

* **Do not use Power BI MCP tools** unless the developer explicitly requests Power BI MCP usage.
* **Never make unsolicited edits to DAX measures in TMDL or PBIP files.** Changes to DAX must be explicitly requested by the developer.
* **DAX output format (default):** When asked for a DAX measure, output in this format only — no `EVALUATE` or `DEFINE` wrappers:
  ```
  Measure Name =
  VAR _something = <expression>
  RETURN
      <result>
  ```
  Always use `VAR`/`RETURN` pattern even for simple expressions. This format pastes directly into the Power BI measure editor.
* **DAX output format (query mode):** Only use `DEFINE MEASURE` / `EVALUATE` syntax when the developer explicitly requests a DAX query (e.g., for use in DAX Studio or the Power BI query view).
* **Power Query edits are permitted** via direct file editing, but keep transformations minimal. The vast majority of business logic lives in warehouse SQL — Power Query is for light reshaping and connection only.
* **Never make speculative or unsolicited changes** to any `.pbip`, `.tmdl`, `.json`, or `.pq` file. Changes must be explicitly requested.
* **DAX measures: output only, never auto-insert.** When asked for DAX measures, provide them as formatted text only — never write them directly into a TMDL file unless the developer says explicitly "add it to the file" or "paste it in" or equivalent. The developer pastes measures into Power BI Desktop themselves.
* **UTF-8 WITHOUT BOM (CRITICAL):** Power BI Desktop requires all `.tmdl` and `.json` PBIP files to be UTF-8 **without** BOM. `Set-Content -Encoding UTF8` in PowerShell 5.1 writes UTF-8 **with** BOM and will break the PBIP. Always use `[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding $false))` when writing these files via PowerShell. To strip an existing BOM: read with `[System.IO.File]::ReadAllBytes`, check for bytes `0xEF 0xBB 0xBF`, decode from offset 3, rewrite with the no-BOM encoder.

---

## Reconciliation Report Design Intent
* The **Reconciliation Report** is designed to mimic the ERP's output as closely as possible, including ERP quirks.
* However, **mimicking the ERP does not mean blindly copying its logic** — each discrepancy must be evaluated. Sometimes we deliberately choose different logic (e.g. cost-at-invoice-time vs current stock cost). Always clarify intent before assuming the ERP behaviour is correct for our model.
* When a gap is found between the Reconciliation Report and the ERP, document whether it is: (a) accepted as immaterial, (b) a known logic difference, or (c) a bug to fix.

### Known Accepted Gaps (Reconciliation Report)

When a gap cannot be fixed through DAX or SQL logic, provide an explanation text for the report's **eye-icon bookmark**. The explanation must state: what the gap is, why it exists, and that it is not caused by missing transactions.

---

## Authoring Model

* PBIP-only workflow.
* Reports are template-first and aligned to the enterprise theme.
* Prefer reusing and extending existing structure over introducing new parallel patterns.

---

## Semantic Model Strategy

* Maintain two primary semantic models:
  1. **Base enterprise model** — canonical model surface.
  2. **Curated / self-service model** — same schema, friendlier naming surface.
* Temporary report-specific models may exist during publication workflows but are not guaranteed schema-compatible until updated.
* **When creating a new thin report, check whether it should live-connect to the branch-specific Base enterprise semantic model.** If the report uses `datasetReference.byConnection`, the committed `definition.pbir` must point to the Dev workspace and Dev Base semantic model on `Dev`, and to the Prod workspace and Prod Base semantic model on `main`.

---

## TMDL Workflow

* New report models start from the latest approved TMDL baseline.
* Preserve schema parity across report models unless a deliberate model-specific exception is approved.
* Never delete shared/core measures used by other reports.
* **Do not edit `relationships.tmdl` directly** unless the developer explicitly asks. Relationship changes are sensitive and must be made manually in Power BI Desktop. Instead, clearly describe the required change (relationship GUIDs, active/inactive toggle, from/to columns) and instruct the developer to make it manually.

---

## Measures And Display Folders

### Core Measures vs Report Measures

**Core measures** are display folders `01`, `02`, `03`, `04`, `05`, `10`, `20` (and their sub-folders). These are:
* `01 - Enterprise`
* `02 - Sales`
* `03 - Service`
* `04 - Orders`
* `05 - Inventory`
* `10 - Used Bikes`
* `20 - Utilities/Hidden`

**Rules for core measures:**
* **Use core measures directly in report visuals wherever possible.** Do not build a report-specific wrapper that simply calls a core measure — use the core measure itself.
* If a core measure needs different blank-handling, a filter override, or report-specific formatting, *then* create a report-specific measure for the appropriate report folder.

**Report measures** live in display folders `51`+. They are only created when the core measure genuinely cannot be used directly for that report context.

### Report-Specific Folder Numbers

Each report has a dedicated numbered prefix in the `00 - Measures` table display folder. These are scoped exclusively to that report:

| Folder prefix | Report |
|---|---|
| `51 - Gross Profit Report` | Gross Profit Report |
| `52 - Order Planner` | Order Planner Activity Report |
| `53 - Activity Report` | Activity Report |
| `54 - Service Report` | Service Report |
| `55 - Reconciliation Report` | Reconciliation Report |
| `56 - Marketing Report` | Marketing Report |
| ...etc | |

### Report Page Sub-Folders

Within a report folder (e.g. `55 - Reconciliation Report`), sub-folders `0`, `1`, `2`, `3`, `4` represent individual report pages:

* `0 - Visual Filters` — filter/guard measures used across pages
* `1 - Sale by Salesperson` — measures for page 1
* `2 - Sale By Make` — measures for page 2
* `3 - Service by Salesperson` — measures for page 3
* `4 - Engineer Performance` — measures for page 4
* ...etc

**Reuse across pages:** If a measure was built for an earlier page sub-folder (e.g. `1 - Sale by Salesperson`) and is needed on a later page (e.g. `2 - Sale By Make`), **reference it directly — do not recreate it**. Only create a new measure if the logic genuinely differs for that page.

### Cleaning Up Unused Report-Specific Measures

* A measure in a report-specific folder that is not referenced in the report's page JSON **and** not called by another measure's DAX is safe to delete.
* Use the analysis scripts in `.tmp/` to identify unused measures before removing any.
* Always back up the TMDL before bulk-removing measures.

---

## Table And Numbering Rules

| Range | Purpose |
|---|---|
| `00` | Measures table |
| `01–39` | Fact tables (ascending by domain) |
| `41–59` | Dimension tables |
| `61–97` | Disconnected / parameter / selector / calculation group tables |
| `98` | Refreshes table (special operational table) |
| `99` | Data From table (Power Query parameter — controls report start date and database connection) |

* Calculation groups use three-digit numbering independent of the table range: `001`, `002`, `003`, etc.
* Do not renumber existing tables without an explicit refactor request — the ranges are load-bearing for report filter context and relationship resolution.

---

## Power Query Standards

* Keep Power Query transformations minimal. Source connections and light column reshaping only.
* Business logic belongs in warehouse SQL, not in Power Query steps.
* **Prefer user-defined functions (UDFs) in Power Query** when the same transformation logic is applied in multiple queries. Recommending a UDF refactor is best practice — flag the opportunity when you see repeated M logic.
* Copilot may edit `.pq` / `m` files directly when explicitly asked.

---

## Approved Tooling

* Use `power_bi/tabular_editor_scripts/` for bulk metadata or refactor operations.
* Keep PBIP JSON/TMDL edits focused and low-churn.

---

## Report Template Workflow

Do not start a new report from scratch. Use the template system to ensure layout, formatting, and structural consistency.

* **Development PBIT (`Development PBIT.pbit`):** Open this when building a new report. It prompts for Data From (start date) and Database (Dev/Prod). A manual TMDL refresh may be needed on first connection.
* **Dev PBIT Project (`Dev PBIT Project.pbip`):** The PBIP version of the template maintained for Git version control and external editor compatibility.
* **Page generation:** Right-click and **Duplicate** the closest pre-built layout tab. Never build directly on the master template tabs. Rename the duplicated tab for your report section.

---

## Layout System

Each template page uses a wireframe placeholder system built from predefined white boxes on a grid.

* **Placeholder borders:** 1px solid `#CBD5E1`.
* **Visual placement:** Place Power BI visuals directly on top of placeholders. Visuals must use a transparent or pure white background so the placeholder border acts as the visual frame.
* **Area types:** `KPI` (single-value cards), `Slicer` (filters/navigation), `Data View` (charts, matrices, tables).

### Standardised Layout Pages

| Layout | Purpose |
|---|---|
| Overview (Product Summary) | Landing page / summary orientation |
| Executive Summary | Top KPI band, large central Data View, supporting Data Views |
| Operational Sidebar | Left-hand slicer column + large central Data View |
| Split Screen | Top slicer bar + two side-by-side Data Views |
| Hero & Detail | Major chart stacked above supporting matrices/tables |
| The Quadrant | 2×2 balanced Data View grid with top KPI band |
| Monitoring | High-density grid for multiple KPIs and operational metrics |
| Drill Through Detail | Hidden full-screen matrix for raw data exports. Accessed via drill-through action or developer-configured button/bookmark only. |

---

## Interaction & Organisation Rules

* **Avoid sync slicers.** If unavoidable, the slicer must remain visible on the active page canvas. The only exception is filtering a hidden Drill Through Detail page.
* **Selection Pane grouping:** Group items logically (`Layout`, `Header`, `Custom Modal`). Layering order must match visual hierarchy — modals on top, shapes at the bottom.
* **Custom Modals:** Use the pre-grouped `Custom Modal` setup. Bookmarks are not pre-configured in the template — manually configure Show/Hide bookmarks and assign to buttons.

---

## Design Standards

### Global Banner (Top Header)

Every page must have a standard 48px header.

* **Background:** Primary Brand Color `#374649` (Charcoal)
* **Text:** Pure White `#FFFFFF`
* **Content:** Report title left-aligned. "Last Refreshed" timestamp far right.

### Typography

* **Primary font:** DIN
* **No Bold rule:** Do not use DIN Bold — it renders poorly. Achieve contrast through size and color only.
* **Light rule:** DIN Light is strictly reserved for body text.

| Element | Style | Size | Color |
|---|---|---|---|
| Main Titles | DIN Regular | 24–28 | `#111111` Pure Black |
| Section Headers | DIN Regular | 14 | `#111111` Pure Black |
| Subtitles | DIN Regular | 14 | `#262626` Soft Black |
| Body Text | DIN Light | 11–12 | `#262626` Soft Black |

### Canvas & Visual Structure

* **Canvas background:** `#F4F6F8` Light Grey
* **Visual backgrounds:** `#FFFFFF` Pure White
* **Internal padding:** 16px on all visuals and text containers. Bounding boxes snap to the grid; padding lets content breathe.
* **Positioning:** Align to whole-number coordinates. Prefer consistent rounded increments to avoid fractional drift in PBIP layout JSON.
* **Dividers:** 1px ultra-light grey horizontal line. Must not touch container edges — maintain left and right margins.
* **No Drop Shadow rule:** Shadows are off for all standard visuals. Exception: hover state on interactive buttons and popup modals only.

---

## Color Strategy

* **Semantic states (reserved):** Red `#EF4444`, Green `#10B981`, Amber `#F59E0B` — for performance-against-target indicators only.
* **Domain coloring:** Metrics are assigned a color family scoped to the individual report. Refer to `domain_colors.md` for hex codes.

### Client White-Labeling

This architecture is designed as a white-label product.

1. Open the `.pbip` repository in VS Code.
2. Global find-and-replace `#374649` with the client's brand hex code.
3. **Warning:** The frame relies on white text over the primary color. Only substitute `#374649` with another **dark** hex code. If the client's brand color is light, keep the Charcoal frame and apply the client's colors to data charts instead.

---

## Cross-Domain Rule

If a Power BI issue originates from reusable business logic or source data mapping, fix it upstream in warehouse SQL rather than patching with isolated report-level logic.
