# ERP Reference Instructions

## Purpose
Use this instruction file when reverse-engineering business logic from recovered ERP source code.

## Source-System Mapping
* Main ERP maps to database schema `raw_ccdata`.
* Website/ecommerce source maps to `raw_css2`.

## Source Code Locations
* Archived and unpacked ERP code is under ignored docs paths:
  1. `docs/source_erp/`
  2. `docs/source_erp_unpacked/`
* These folders are reference-only and are intentionally ignored from commits.

## Usage Rules
* Use recovered C# code only when warehouse SQL lineage and schema analysis are insufficient to confirm business rules.
* Prefer tracing behavior in this order:
  1. SQL lineage (`docs/warehouse_lineage_context.mmd` + SQL objects)
  2. ERP C# source confirmation
  3. Translate confirmed rule into warehouse SQL
* Never treat recovered ERP code as deployable warehouse code.

## Safety And Disclosure
* Do not copy large source excerpts into tracked docs or commits.
* Summarize behavior and cite source paths minimally when needed for auditability.