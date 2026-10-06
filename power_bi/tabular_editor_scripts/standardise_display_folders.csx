// ============================================================
// standardise_display_folders.csx
// ============================================================
// Tabular Editor C# script to standardise measure display
// folders in the Enterprise SEM 2 model.
//
// Changes applied:
//   1. Rename "01 - Merchandise" → "01 - Sales" in all display folders
//   2. Standardise Service subfolders to use numbered tiers:
//        "02 - Service\Base\..."    → "02 - Service\1 - Base\..."
//        "02 - Service\Standard..." → "02 - Service\2 - Standard..."
//
// Usage:
//   Open the model in Tabular Editor → Advanced Scripting →
//   paste and run (Ctrl+Shift+X). Review changes in the
//   Properties pane. Save (Ctrl+S) to persist to TMDL.
// ============================================================

int changeCount = 0;

foreach (var m in Model.AllMeasures)
{
    string original = m.DisplayFolder;
    string updated = original;

    // 1. Rename Merchandise → Sales
    if (updated.StartsWith("01 - Merchandise"))
    {
        updated = "01 - Sales" + updated.Substring("01 - Merchandise".Length);
    }

    // 2. Standardise Service sub-tier numbering
    if (updated.StartsWith("02 - Service\\Base"))
    {
        updated = "02 - Service\\1 - Base" + updated.Substring("02 - Service\\Base".Length);
    }
    else if (updated.StartsWith("02 - Service\\Standard"))
    {
        updated = "02 - Service\\2 - Standard" + updated.Substring("02 - Service\\Standard".Length);
    }

    if (updated != original)
    {
        m.DisplayFolder = updated;
        changeCount++;
    }
}

Info("Updated " + changeCount + " measure display folders.");
