var targetTable = Model.Tables["00 - Measures"];

if (targetTable != null)
{
    int updatedCount = 0;

    foreach (var measure in targetTable.Measures)
    {
        // Look for the % sign in the measure name
        if (measure.Name.Contains("%"))
        {
            // "0%" is the correct mathematical format string. 
            // Power BI will read this, format it correctly on the canvas, 
            // unlock your decimal controls, and assign it to the Percentage category.
            measure.FormatString = "0%";
            updatedCount++;
        }
    }
    
    
}
else
{
    Error("Table '00 - Measures' could not be found.");
}