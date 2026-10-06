# Power BI — Cycle Superstore Analytics

This directory contains all PBI assets for the Cycle Superstore analytics platform. Everything is stored in **PBIP (Power BI Project)** format for source control.


---

## Directory Structure

```
power_bi/
├── semantic_models/                   ← Shared semantic model projects
│   ├── main/                          ← Enterprise Base (production model)
│   └── curated/                       ← Curated self-service model
├── thin_reports/                      ← Thin report projects
│   ├── activity/
│   ├── gross_profit/
│   ├── marketing/
│   ├── order_detail/
│   ├── products/
│   ├── reconciliation/
│   ├── service/
│   └── transaction/
├── tabular_editor_scripts/            ← Reusable C# scripts for Tabular Editor
│   ├── delete_unreferenced_measures_in_folder.csx
│   ├── disable_implicit_measures.csx
│   └── set_pk_and_hide_fk_columns.csx
└── themes/
    └── Enterprise Theme.json          ← Standard JSON theme for all reports
```

---

## Enterprise SEM 2 — The Production Model

**Path:** `semantic_models/main/`

Enterprise_Base is the single source of truth for all reporting. Other reports pull the data to their models using the ALM Toolkit when using the thin reports structure, and changes are pushed back.

### Connection

- **Server:** `css-sql-prd-neu.database.windows.net`
- **Compatibility level:** 1702
- **Data From parameter:** Controls the earliest date loaded (default: `2024-01-01`)

---

## Table Numbering Convention

Every table in the model is prefixed with a **two-digit number** that controls sort order in the Power BI field list and communicates the table's role at a glance.

### 00 — Measures Table

| # | Table | Purpose |
|---|---|---|
| **00** | Measures | Holds all DAX measures; single hidden `Placeholder` column. No data columns visible to report authors. |

### 01 – 19 — Fact Tables

| # | Table | Description |
|---|---|---|
| 01 | Order Invoices | Merchandise invoices placed through the order channel |
| 02 | Till Invoices | Merchandise invoices placed at the till (POS) |
| 03 | Service Invoices | Workshop/service invoices |
| 04 | Used Bikes | Used-bike consignment sales (memo-based) |
| 05 | Order Credits | Credit notes against order invoices |
| 06 | Till Credits | Credit notes against till invoices |
| 07 | Service Credits | Credit notes against service invoices |
| 08 | Sales Orders | Open/pending merchandise orders (pipeline) |
| 09 | Service Orders | Open/pending service/repair orders (pipeline) |
| 10 | Inventory | Daily stock-on-hand snapshot (T1 + Cara warehouses) |
| 11 | Emails | Exchange email activity linked to customers |
| 12 | Purchase Orders | Supplier purchase orders |

Numbers 13 – 19 are reserved for future fact tables.

### 41 – 49 — Dimension Tables

| # | Table | Description |
|---|---|---|
| 41 | Date | DAX-generated date dimension (`dataCategory: Time`) |
| 42 | Stock | Product/stock dimension — the largest dimension (brand, title, category) |
| 44 | Employee | Employee dimension (salesperson, engineer) |
| 45 | Order Channel | Degenerate dimension for order channel classification |
| 46 | Time | DAX-generated time-of-day dimension (minute granularity) |

Numbers 43, 47 – 49 are reserved for future dimensions (e.g. Location/Store).

### 51 – 59 — Disconnected / Selector / Bridge Tables

| # | Table | Type | Purpose |
|---|---|---|---|
| 51 | Metric Selection | Field parameter | Dynamic measure swapping in visuals |
| 52 | Link Mode | DAX calculated | VPN vs Internal URL toggle |
| 53 | Customer | Import (SQL) | Customer dimension (import mode for performance) |
| 53 | Product Status Selector | DAX calculated | Current / New / Discontinued filter |
| 54 | Order Factor | DAX calculated | What-if parameter (0.20 – 1.50) for order planning |
| 55 | Used Bikes Invoices Toggle | DAX calculated | Include/exclude used bikes from invoice totals |
| 56 | Brand Bridge | DAX calculated | Cross-filter bridge for brand slicer |
| 56 | Model Year Bridge | DAX calculated | Cross-filter bridge for model-year slicer |

### 98 – 99 — Metadata / Refresh Tracking

| # | Table | Purpose |
|---|---|---|
| 98 | Refreshes | Tracks table-level refresh timestamps and layer names |
| 99 | Data From | Surfaces the `Data From` parameter for DAX reference |

**Rule:** When adding a new table, pick the **next available number** within the correct range. Never reuse a retired number in a different range.

---

## Measures Display Folder Convention

All core measures live on `'00 - Measures'`. They are organised into display folders with **numbered prefixes** that create predictable sort order and clear zones of responsibility.

### Zone 1 — Core Business Domains (01 – 19)

These folders are **shipped to every downstream model** via ALM Toolkit. Each domain follows a standardised internal hierarchy:

```
XX - Domain Name
├── 1 - Base                         ← Raw SUM / COUNT from individual fact tables
│   ├── Split Facts                  ← Per-fact breakdowns
│   │   ├── Order Invoices
│   │   ├── Till Invoices
│   │   ├── Order Credits
│   │   └── Till Credits
│   └── Consolidated                 ← Combined measures across related facts
│       ├── Invoices                 ← e.g. Order + Till Invoices
│       └── Credits                  ← e.g. Order + Till Credits
├── 2 - Standard                     ← Business-level KPIs built on base measures
│   ├── Invoice                      ← Invoice averages, counts
│   ├── Credit                       ← Credit averages, counts
│   ├── Net                          ← Invoices minus Credits
│   └── Key Measures                 ← Headline metrics for executive dashboards
└── 3 - Time Intelligence            ← (Future) YTD / QTD / PY / POP patterns
```

Not every domain needs all sub-levels. Simpler domains (e.g. Marketing, Used Bikes Memo) may only have `1 - Base` and `2 - Standard`.

**Current domains:**

| # | Folder | Contents |
|---|---|---|
| 01 | Sales | Goods revenue — order invoices, till invoices, order credits, till credits, net sales, averages |
| 02 | Service | Service invoices, service credits, service KPIs |
| 03 | Enterprise | Cross-departmental metrics (Total Revenue = Sales + Service) |
| 04 | Orders | Sales orders (merchandise pipeline) + service orders (repair pipeline) |
| 05 | Inventory | Stock on hand, inventory quantities, daily averages |
| 06 | Marketing | Marketing & advertising metrics (placeholder) |
| 07 | Used Bikes Memo | Used-bike consignment stock measures |

Numbers 08 – 19 are reserved for future domains (e.g. Purchasing, CRM, HR).

### Zone 2 — System Folders (20 – 39)

| # | Folder | Purpose |
|---|---|---|
| 20 | Utilities/Hidden | Helper measures not tied to a single domain — URL builders, conditional-display flags (`Show Value For Dates`), date/week formatters. Typically hidden from report authors via the `isHidden` property. |
| 30 | Saved/Pending | Work-in-progress measures, experimental patterns (e.g. SQLBI time intelligence templates), measures awaiting assignment to a domain. **Not promoted** to downstream models. |

Numbers 21 – 29 and 31 – 39 are reserved.

### Zone 3 — Report-Specific Folders (71 – 89)

These measures **stay in the Enterprise model** but are only selectively copied to the specific downstream model that needs them. When using **ALM Toolkit** to push measures to a downstream model:

1. Copy all Zone 1 (core) and Zone 2 (system) folders — these go to every model.
2. Copy **only the single report-specific folder** that matches the target model.
3. Delete all other report-specific folders from the target.

| # | Folder | Target Report | Sub-structure |
|---|---|---|---|
| 71 | Gross Profit Report | Gross Profit report | `Base`, `Formatted`, `Other`, `YTD CY`, `YTD LY`, `YTD Change`, `YTD Change\%` |
| 72 | Order Planner Measures | Order Planner report | `Base`, `Derived`, `StockQty` |
| 73 | Activity Report | Activity Report | (flat) |
| 74 | Service Report | Service Report | (flat) |
| 76 | Validation Report | Validation Report | (flat, ERP reconciliation measures) |

Numbers 75, 77 – 89 are available for future reports.

### Measure Naming Patterns

| Layer | Pattern | Example |
|---|---|---|
| Base (Split Facts) | `{Fact Table Name} {Aggregation}` | `Order Invoices Amount`, `Till Credits VAT` |
| Base (Consolidated) | `{Domain} {Aggregation Type} {Metric}` | `Sales Gross Invoices Amount` |
| Standard (Derived) | `{Domain} {KPI Name}` | `Sales Average Invoice Amount` |
| Time Intelligence | `{Metric} {TI Suffix}` (SQLBI pattern) | `Gross Sales YTD`, `Gross Sales YOY %` |

---

## Tabular Editor Scripts

Reusable C# scripts for bulk operations in [Tabular Editor](https://tabulareditor.com/):

| Script | Purpose |
|---|---|
| `delete_unreferenced_measures_in_folder.csx` | Removes measures in a specified display folder that are not referenced by any other measure or visual |
| `disable_implicit_measures.csx` | Sets `SummarizeBy = None` on all columns to prevent Power BI from auto-creating implicit measures |
| `set_pk_and_hide_fk_columns.csx` | Marks primary key columns and hides foreign key columns based on relationships |

---

## Themes

Standard theme file: `themes/Enterprise Theme.json`

All reports should use this theme for consistent formatting (colours, fonts, visual defaults).
