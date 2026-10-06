// =============================================================================
// Disable Implicit Measures on All Columns
// =============================================================================
// Sets SummarizeBy = None on every non-calculated column in the model so that
// Power BI cannot auto-generate implicit measures (sum, average, count, etc.).
// This forces report authors to use explicit DAX measures only.
//
// Safe to run repeatedly — already-disabled columns are skipped in the count.
// =============================================================================

int updated = 0;
int skipped = 0;

foreach (var col in Model.AllColumns)
{
    if (col.SummarizeBy != AggregateFunction.None)
    {
        col.SummarizeBy = AggregateFunction.None;
        updated++;
    }
    else
    {
        skipped++;
    }
}

Info(
    "Implicit measures disabled.\n\n"
  + "  • " + updated + " column(s) updated to SummarizeBy = None.\n"
  + "  • " + skipped + " column(s) were already set to None (unchanged)."
);
