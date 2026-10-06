# Enterprise Color Dictionary

Use these hex codes to maintain semantic consistency for visuals across all reports.
**Rule:** Never use Semantic colors for categorical splits. Use the Standard Theme Palette for general charting.

## 1. The Performance Palette (Semantic States)

*Strictly reserved for tracking performance against predefined targets, KPIs, or baselines.*

* **Positive / Good:** `#91FFDB` (Emerald Green)
* **Warning / At Risk:** `#F59E0B` (Bright Amber)
* **Negative / Bad:** `#FEA8A8` (Bright Red)

## 2. The Financial Palette (Semantic Metrics)

*Strictly reserved for specific high-level financial measures. When visualizing a child measure (e.g., "Service Cost"), use the same hex code to maintain visual association.*

* **Revenue (Inflows):** `#1D4ED8` (Strong Denim Blue)
* **Profit (Gains):** `#0F766E` (Dark Seaweed Teal)
* **Cost (Outflows):** `#9F1239` (Deep Burgundy Rose)

## 3. The Standard Theme Palette (Categorical)

*These are the default 6 colors loaded into the Power BI Theme. Use these for all standard categorical plotting (e.g., Regions, Transaction Types, Product Categories) where the data does NOT represent a specific financial or performance state. The sequence is optimized for contrast.*

1. `#777EF6` (Vibrant Indigo) - *First category color for general use.*
2. `#71CC75` (Mint Green) - *Secondary color for categorical splits.*
3. `#F5C4AF` (Soft Coral) - *Tertiary color for categorical splits.*
4. `#41A4FF` (Bright Sky Blue) - *Quaternary color for categorical splits.*
5. `#E8D166` (Warm Mustard) - *Quinary color for categorical splits.*
6. `

---

### Implementation Rules for Developers

* **Single-Measure Charts:** If plotting a single financial metric (e.g., a line chart showing only "Total Cost" over time), color the line with the designated Financial Palette color (`#9F1239`).
* **Multi-Measure Categorical Charts:** If plotting multiple non-semantic categories (e.g., Qty Invoice vs. Qty Service vs. Qty Sundry), rely on the Standard Theme Palette. The Power BI theme will automatically assign the first 3 colors from the list above.
* **The "Collision" Rule:** Never manually assign a color from the Performance or Financial palettes to a random category. (e.g., Do not assign `#10B981` Green to "Store A" just to make it stand out, as users will assume Store A is performing above target).
