// =============================================================================
// Delete Unreferenced Measures in Display Folder
// =============================================================================
// Finds every measure in the specified display folder that is:
//   (a) not referenced by any other DAX expression in the model, AND
//   (b) not referenced in any report page JSON file (PBIP format).
//
// Usage:
//   1. Open the script in Tabular Editor 2 or 3 (Advanced Scripting).
//   2. Set targetFolder and reportFolderPath below.
//   3. Run.  A preview dialog lists what will be deleted — confirm to proceed.
//
// Notes:
//   • reportFolderPath should point to the report's definition/pages/ folder
//     (or the definition/ folder — any subfolder containing .json page files).
//     If left empty, only DAX references are checked (report visuals are ignored).
//   • The operation is undoable with Ctrl+Z in Tabular Editor 2.
// =============================================================================

var targetFolder = "76 - Validation Report";
// Path to the PBIP report's page definition folder so visual references are checked.
// Example: @"C:\Git_Repositories\cycle-superstore-analytics\power_bi\thin_reports\Validation Report\Validation Report.Report\definition\pages"
var reportFolderPath = @"C:\Git_Repositories\cycle-superstore-analytics\power_bi\thin_reports\Validation Report\Validation Report.Report\definition\pages";

// ── Build set of measure names mentioned in report JSON files ─────────────────
var namesInReport = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);

if (!string.IsNullOrWhiteSpace(reportFolderPath) && System.IO.Directory.Exists(reportFolderPath))
{
    foreach (var file in System.IO.Directory.GetFiles(reportFolderPath, "*.json", System.IO.SearchOption.AllDirectories))
    {
        var content = System.IO.File.ReadAllText(file);
        foreach (var m in Model.AllMeasures)
        {
            // A quoted occurrence of the measure name in the JSON is sufficient evidence it's used.
            if (content.Contains("\"" + m.Name + "\""))
                namesInReport.Add(m.Name);
        }
    }
}

// ── Find candidates ──────────────────────────────────────────────────────────
var candidates = Model.AllMeasures
    .Where(m => string.Equals(m.DisplayFolder, targetFolder, StringComparison.OrdinalIgnoreCase))
    .ToList();

if (!candidates.Any())
{
    Info("No measures found in display folder '" + targetFolder + "'.\n\n"
       + "Check that the folder name (including case) matches exactly what "
       + "appears in Tabular Editor.");
    return;
}

var unreferenced = candidates
    .Where(m => m.ReferencedBy.Count == 0 && !namesInReport.Contains(m.Name))
    .OrderBy(m => m.Name)
    .ToList();

if (!unreferenced.Any())
{
    var checkedReport = !string.IsNullOrWhiteSpace(reportFolderPath) && System.IO.Directory.Exists(reportFolderPath);
    Info("All " + candidates.Count + " measure(s) in '" + targetFolder + "' are in use "
       + "(referenced by another DAX expression" + (checkedReport ? " or found in report page files" : "") + ")."
       + "\n\nNothing to delete.");
    return;
}

// ── Confirmation dialog ───────────────────────────────────────────────────────
var summary = string.Join("\n", unreferenced.Select(m => "  • [" + m.Table.Name + "] " + m.Name));

var result = System.Windows.Forms.MessageBox.Show(
    "Found " + unreferenced.Count + " unreferenced measure(s) in '"
        + targetFolder + "' (out of " + candidates.Count + " total):\n\n"
        + summary
        + "\n\nThese measures are not referenced by any other DAX expression in the model"
        + (namesInReport.Count > 0 ? ", and do not appear in any report page JSON file" : "")
        + ".\n\nDelete all of them?",
    "Delete Unreferenced Measures",
    System.Windows.Forms.MessageBoxButtons.YesNo,
    System.Windows.Forms.MessageBoxIcon.Warning
);

if (result != System.Windows.Forms.DialogResult.Yes)
{
    Info("Cancelled — no measures were deleted.");
    return;
}

// ── Delete ────────────────────────────────────────────────────────────────────
foreach (var m in unreferenced)
    m.Delete();

Info("Deleted " + unreferenced.Count + " unreferenced measure(s) from '"
   + targetFolder + "'.\n\nUse Ctrl+Z to undo if needed before saving.");
