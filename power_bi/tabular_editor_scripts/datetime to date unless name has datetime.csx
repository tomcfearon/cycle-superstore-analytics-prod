int updatedCount = 0;

// Regex pattern: "date", optional underscore ("_?"), "time". Case-insensitive.
var excludeRegex = new System.Text.RegularExpressions.Regex(@"date_?time", System.Text.RegularExpressions.RegexOptions.IgnoreCase);

// Loop through every table in the model
foreach (var table in Model.Tables)
{
    // Loop through every column in the current table
    foreach (var column in table.Columns)
    {
        // 1. Check if the underlying data type is DateTime
        if (column.DataType == DataType.DateTime)
        {
            // 2. Check if the column name does NOT contain our "datetime" pattern
            if (!excludeRegex.IsMatch(column.Name))
            {
                // 3. Set to "Short Date" (Power BI's way of treating it as a simple Date)
                column.FormatString = "Short Date";
                updatedCount++;
            }
        }
    }
}

