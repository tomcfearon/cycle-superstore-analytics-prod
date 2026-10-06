// ============================================================
// rename_merchandise_to_sales.csx
// ============================================================
// Tabular Editor C# script to rename every measure that
// contains "Merchandise" in its name, replacing it with "Sales".
//
// Also updates any display folder path containing "Merchandise"
// to use "Sales" instead.
//
// Usage:
//   Open the model in Tabular Editor → Advanced Scripting →
//   paste and run (Ctrl+Shift+X). Review changes. Save (Ctrl+S).
// ============================================================

int nameCount = 0;
int folderCount = 0;

foreach (var m in Model.AllMeasures)
{
    // Rename measure name
    if (m.Name.Contains("Merchandise"))
    {
        m.Name = m.Name.Replace("Merchandise", "Sales");
        nameCount++;
    }

    // Update display folder
    if (m.DisplayFolder.Contains("Merchandise"))
    {
        m.DisplayFolder = m.DisplayFolder.Replace("Merchandise", "Sales");
        folderCount++;
    }
}

Info("Renamed " + nameCount + " measures. Updated " + folderCount + " display folders.");
