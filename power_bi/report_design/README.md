# Power BI Enterprise UX/UI Standards

This repository contains the foundational design system and template files for all client Power BI reporting.

## The Template Workflow

Do not start a new report from scratch. Use the template system to ensure layout, formatting, and structural consistency. The required JSON Theme file is already imported and active within these templates.

### 1. Development PBIT (`Development PBIT.pbit`)

When building a new report, open this file first.

* Upon opening, it will prompt you to choose your **Data From** (Start Date) and select your **Database** (Dev/Prod).
* *Note:* You may need to manually refresh the semantic layer (paste in latest TMDL model) upon initial connection to pull in the full schema.

### 2. Dev PBIT Project (`Dev PBIT Project.pbip`)

This folder contains the Power BI Project version of the template.

* We maintain this format so the underlying structural files (JSON, TMDL) can be version-controlled in Git and edited using external text editors or developer tools.

### 3. Page Generation (Duplication)

The PBIT contains several pre-built layout tabs.

* **Do not build directly on the master template tabs.** * Instead, right-click and **Duplicate** the layout that best fits your needs, rename the newly duplicated tab for your specific report section, and build on top of that.

---

## The PBIT Layout System

To maintain uniformity, the PBIT utilizes a strictly defined wireframe placeholder system.

### Placeholder Shapes & Layering

Each layout features predefined blank white boxes mapped to a grid.

* **Styling:** These shapes have a 1px solid border using the color `#CBD5E1`.
* **Text Labels:** Each box contains internal text detailing its purpose (e.g., `KPI`, `Slicer`, or `Data View`). *Note: End-users will never see this text.*
* **Implementation:** You will place your actual Power BI visuals directly on top of these placeholder shapes. Ensure your visuals have a transparent or pure white background so they sit seamlessly over the shape, utilizing the shape's border as the visual's frame.

### Area Definitions

* **KPI:** Reserved for single-value metrics or cards.
* **Slicer:** Reserved for filtering controls or navigation buttons.
* **Data View:** Reserved for any chart, graph, matrix, or table visual.

### Standardized Layout Pages

The template includes the following base layouts for duplication:

* **Overview (Product Summary):** Use the existing `Overview` layout for landing-page and product-summary scenarios, featuring links or summary content that orient the user before deeper report sections.
* **Executive Summary:** A high-level view featuring a top KPI band, a large central Data View, and smaller supporting Data Views.
* **Operational Sidebar:** Features a dedicated left-hand column for Slicers and a massive central Data View.
* **Split Screen:** A centralized top Slicer bar with two large, side-by-side Data Views for direct comparisons.
* **Hero & Detail:** A stacked layout prioritizing one major chart on top with supporting matrices/tables below.
* **The Quadrant:** A balanced 2x2 grid of Data Views, typically supported by a top KPI band.
* **Monitoring:** A high-density grid designed for tracking multiple specific KPIs and operational metrics at a glance.
* **Drill Through Detail:** A *hidden* page consisting of a single, full-screen Data View (usually a Matrix) dedicated specifically to raw data exports. **This page is not meant for standard navigation; it must be accessed via a configured drill-through action or a specific button/bookmark set up by the developer.**

---

## Interaction & Organization Rules

### Sync Slicers Rule

* **Avoid sync slicers whenever possible.** * **Exception:** If you *must* use sync slicers, the slicer **must remain visible** on the canvas of the active page. The only exception to this visibility rule is when passing filters to a hidden **Drill Through Detail** page.

### The Selection Pane

Layering and grouping are critical for developer hand-offs. Each template page demonstrates the strict grouping structure you must follow in the Selection Pane:

* Group items logically (e.g., `Layout`, `Header`, `Custom Modal`).
* Ensure layering order matches the visual hierarchy (modals on top, shapes on the bottom).

### Custom Modals & Popups

Template pages include a pre-grouped `Custom Modal` setup in the Selection Pane, which includes a background dimming scrim and the popup content, along with an optional Info Button or External Link in the Header group.

* **Important:** Due to Power BI limitations, bookmarks are not pre-configured in the template. You must manually set up the "Show/Hide" bookmarks and assign them to your buttons when utilizing the modal.

---

## Design Philosophy & Formatting

Our goal is to reduce cognitive load. We rely on strict typography rules, intentional white space, and specific color domains rather than heavy decoration.

### The Global Banner (Top Header)

Every page must feature the standard 48px global header.

* **Background Color:** Primary Brand Color (`#374649` - Charcoal)
* **Text Color:** Pure White (`#FFFFFF`)
* **Layout:** Report title on the left. **"Last Refreshed"** timestamp on the far right.

### Typography & Text Box Standards

* **Primary Font Family:** DIN
* **The "No Bold" Rule:** Do NOT use DIN Bold. It renders poorly. Contrast is achieved through size and color.
* **The "Light" Rule:** DIN Light is strictly reserved optionally for Body text only.

**Text Box Formatting Guidelines (The Hierarchy):**

* **Main Titles:** DIN Regular, Size 24-28. Color: Pure Black (`#111111`). *(Must be the darkest text element).*
* **Section Headers:** DIN Regular, Size 14. Color: Pure Black (`#111111`).
* **Body Text:** DIN Light, Size 11-12. Color: Soft Black (`#262626`).
* **Subtitles:** DIN Regular, Size 14. Color: Soft Black (`#262626`).

### Structure, Padding, & Elements

* **The Canvas:** Light Grey (`#F4F6F8`)
* **Visual Backgrounds:** Pure White (`#FFFFFF`)
* **Padding:** All visuals and text containers must utilize a strict **16px internal padding**. This allows bounding boxes to snap together on the grid while letting the data inside breathe.
* **Positioning:** Keep headers, containers, and visuals aligned to whole-number coordinates and prefer consistent rounded increments across pages to avoid fractional drift in the PBIP layout JSON.
* **Dividers:** When using a horizontal line to separate text sections, use a 1px ultra-light grey line. **Rule:** Dividers must not touch the edges of the container; maintain left and right margins so the line floats within the text block.
* **The "No Drop Shadow" Rule:** Shadows cause rendering lag and visual clutter. Turn them off for all standard visuals.
  * *Exception:* Shadows are strictly reserved for **Interactive Buttons on Hover** or **Popups** to provide user feedback.

---

## Color Strategy & White-Labeling

* **Semantic States:** Red (`#EF4444`), Green (`#10B981`), and Amber (`#F59E0B`) are strictly reserved for performance against targets. These are globally saved within the JSON theme file.
* **Domain Coloring:** Metrics are assigned a specific color family scoped to the individual report. Refer to `domain_colors.md` for exact hex codes.

### Client White-Labeling (Mass Replacement)

This architecture is designed to act as a white-label product. If a specific client requires their own corporate branding for the overall application frame:

1. Open the `.pbip` repository in a text editor (e.g., VS Code).
2. Perform a global "Find and Replace" for the default Primary Brand Color (`#374649`) and replace it with the client's requested Hex code.
3. *Warning:* The structural UI relies on white text over the Primary Brand Color. You must only substitute `#374649` with another **dark** hex code to maintain accessibility and contrast. If the client's brand color is light, retain the default Charcoal frame and apply the client's colors to the data charts instead.
