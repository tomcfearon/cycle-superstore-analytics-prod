# Azure Data Factory Instructions

## Scope
Use this instruction file for all edits under `data_platform/adf/`.

## High-Risk JSON Editing Rules
* Make minimal-diff edits only: change the fewest properties required for the task.
* Do not pretty-print entire files or reorder JSON properties unless functionally required.
* Do not rename existing ADF assets unless there is a clear functional reason.
* Never perform broad "cleanup" rewrites on ADF JSON.

## Naming Rules For New ADF Assets
* Use stable, descriptive names that communicate domain and action intent.
* Prefer snake_case for new assets when practical.
* When interoperating with existing non-snake_case names, keep consistency with adjacent artifacts.
* **Activity names must be unique within a pipeline.** When the same logical activity (e.g. `GetWatermark`, `GetMaxTimestamp`) appears in multiple ForEach activities inside the same pipeline, append a numeric suffix to make each name unique (e.g. `GetWatermark2`, `GetMaxTimestamp2`). ADF will reject duplicate activity names at validation time.

## ADF Expression Functions
* Use `json()` to parse a JSON string into an object in ADF expressions. Do **not** use `createObject()` — it is not a valid ADF expression function and will fail at runtime.
* `createArray()` IS valid for building arrays in ADF expressions.

## Environment Safety
* Dev factory only for repository-driven changes.
* Keep Dev trigger definitions stopped in source control.
* Do not change secrets/credentials in committed linked service JSON.
* Default behavior is repository file editing only; do not execute cloud-side ADF mutations unless the user explicitly requests cloud execution.
* If cloud execution is requested, scope to Dev only unless the user explicitly asks for another environment.

## Change Checklist
Before finalizing an ADF edit:
1. Confirm only required properties changed.
2. Confirm no accidental object reorder/format churn.
3. Confirm triggers remain stopped for Dev.
4. Summarize exact JSON paths/properties changed.

## External Guidance Policy
* Prefer Microsoft Learn and official Azure docs when additional ADF behavior guidance is needed.
* Summarize external guidance into repository-owned notes instead of depending on ad hoc downloaded files.
