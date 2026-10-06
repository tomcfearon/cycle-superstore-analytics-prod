// Pure Number-Based Cleanup Script for Tabular Editor 2

// Regex to capture the number and the rest of the table name
var prefixRegex = new System.Text.RegularExpressions.Regex(@"^(\d{1,2})\s*-\s*(.*)");

// Pass 1: Rename, Delete, and Hide at the Table Level
foreach (var table in Model.Tables.ToList())
{
    var tableMatch = prefixRegex.Match(table.Name);
    int tableNum = -1;
    string cleanTableName = table.Name;
    
    // Extract number if it exists
    if (tableMatch.Success)
    {
        tableNum = int.Parse(tableMatch.Groups[1].Value);
        cleanTableName = tableMatch.Groups[2].Value.Trim();
    }
    // Fallback ONLY for the main Metrics/Measures table in case it was already renamed
    else if (table.Name.Equals("Metrics", StringComparison.OrdinalIgnoreCase) || 
             table.Name.Equals("Measures", StringComparison.OrdinalIgnoreCase))
    {
        tableNum = 0; 
    }

    // Skip tables that don't have a number (and aren't the Metrics table)
    if (tableNum == -1) continue;

    // ---------------------------------------------------------
    // 00: SAVED (Metrics)
    // ---------------------------------------------------------
    if (tableNum == 0)
    {
        table.Name = "Metrics"; 

        foreach (var measure in table.Measures.ToList())
        {
            string folder = measure.DisplayFolder;
            if (!string.IsNullOrEmpty(folder))
            {
                string rootFolder = folder.Split('\\')[0];
                var folderMatch = prefixRegex.Match(rootFolder);

                if (folderMatch.Success)
                {
                    int folderNum = int.Parse(folderMatch.Groups[1].Value);
                    
                    // Folders 20 and up are deleted
                    if (folderNum >= 20) 
                    {
                        measure.Delete();
                    }
                    // Folders under 20 have their numbers stripped
                    else
                    {
                        measure.DisplayFolder = System.Text.RegularExpressions.Regex.Replace(folder, @"(^|\\)\d{1,2}\s*-\s*", "$1");
                    }
                }
                // Fallback catch for Utilities/Hidden folders
                else if (rootFolder.IndexOf("Utilities", StringComparison.OrdinalIgnoreCase) >= 0 || 
                         rootFolder.IndexOf("Hidden", StringComparison.OrdinalIgnoreCase) >= 0) 
                {
                    measure.Delete();
                }
            }
        }
    }
    
    // ---------------------------------------------------------
    // 01 to 40: HIDDEN (Facts)
    // ---------------------------------------------------------
    else if (tableNum >= 1 && tableNum <= 40)
    {
        table.Name = cleanTableName; // Strips the number
        table.IsHidden = true; 
    }
    
    // ---------------------------------------------------------
    // 41 to 60: DISPLAYED (Dimensions)
    // ---------------------------------------------------------
    else if (tableNum >= 41 && tableNum <= 60)
    {
        table.Name = cleanTableName; // Strips the number
        table.IsHidden = false; 
    }
    
    // ---------------------------------------------------------
    // 61 to 90: DELETED (Disconnected/Junk)
    // ---------------------------------------------------------
    else if (tableNum >= 61 && tableNum <= 90)
    {
        table.Delete(); 
    }
    
    // ---------------------------------------------------------
    // 91+: HIDDEN (System/Backend Tables)
    // ---------------------------------------------------------
    else if (tableNum > 90)
    {
        // Does NOT rename them to preserve Power Query backend references
        table.IsHidden = true; 
    }
}

// Pass 2: The "Report View Bug" Fix
// Ensures that any table marked as hidden also hides all of its internal contents
foreach (var table in Model.Tables)
{
    if (table.IsHidden)
    {
        foreach (var col in table.Columns) col.IsHidden = true;
        foreach (var measure in table.Measures) measure.IsHidden = true;
        foreach (var hier in table.Hierarchies) hier.IsHidden = true;
    }
}