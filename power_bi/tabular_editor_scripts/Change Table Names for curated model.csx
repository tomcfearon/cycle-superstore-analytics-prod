// Set your preferred name for the Measures table here:
string measuresTableNewName = "Metrics"; 
// Alternatives: "Measures", "KPIs", "Calculations", "Business Metrics"

// Loop through all tables
foreach (var table in Model.Tables)
{
    // Handle Measures table rename
    if (table.Name.StartsWith("00 - "))
    {
        table.Name = measuresTableNewName;
        continue;
    }

    // Remove "NN - " prefix (e.g., "01 - Sales" -> "Sales")
    if (table.Name.Length > 5 && table.Name[2] == ' ' && table.Name[3] == '-' && table.Name[4] == ' ')
    {
        table.Name = table.Name.Substring(5);
    }
}