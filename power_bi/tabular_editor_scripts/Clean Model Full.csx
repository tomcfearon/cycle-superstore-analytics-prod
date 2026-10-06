using System;
using System.Linq;
using System.Text.RegularExpressions;

// Create a static list of tables so we can safely delete items while iterating
foreach (var table in Model.Tables.ToList()) 
{
    var match = Regex.Match(table.Name, @"^(\d{2})\s*-\s*(.*)");
    
    if (match.Success) 
    {
        int prefix = int.Parse(match.Groups[1].Value);
        string cleanName = match.Groups[2].Value.Trim();
        
        // Exception for Tables 98 & 99: Hide them, but DO NOT rename them to avoid M Engine conflicts
        if (prefix == 98 || prefix == 99)
        {
            table.IsHidden = true;
        }
        else if (prefix > 60) 
        {
            // Remove the table if the prefix is 61 or higher (excluding 98 and 99)
            table.Delete();
        } 
        else 
        {
            // Identify if this is the Measures table so we can apply specific folder logic
            bool isMeasuresTable = cleanName.Equals("Measures", StringComparison.OrdinalIgnoreCase);
            
            if (isMeasuresTable)
            {
                table.Name = "Metrics";
            }
            else
            {
                table.Name = cleanName;
            }
            
            // Loop through a static list of measures
            foreach (var measure in table.Measures.ToList()) 
            {
                if (!string.IsNullOrEmpty(measure.DisplayFolder))
                {
                    // Apply folder prefix logic ONLY to the Measures/Metrics table
                    if (isMeasuresTable) 
                    {
                        var folderMatch = Regex.Match(measure.DisplayFolder, @"^(\d{2})\s*-\s*(.*)");
                        if (folderMatch.Success)
                        {
                            int folderPrefix = int.Parse(folderMatch.Groups[1].Value);
                            
                            // Remove the folder assignment for prefixes 20 and above
                            if (folderPrefix >= 20)
                            {
                                measure.DisplayFolder = string.Empty;
                            }
                            else
                            {
                                // Strip the prefix and dash from the folder name
                                measure.DisplayFolder = folderMatch.Groups[2].Value.Trim();
                            }
                        }
                    }

                    // Rename display folders from _direct measures to _direct metrics
                    // Added a check to ensure it's not null after potentially clearing it above
                    if (!string.IsNullOrEmpty(measure.DisplayFolder) && measure.DisplayFolder.Contains("_direct measures")) 
                    {
                        measure.DisplayFolder = measure.DisplayFolder.Replace("_direct measures", "_direct metrics");
                    }
                }
            }
            
            // Rename display folders for all Columns 
            foreach (var column in table.Columns.ToList()) 
            {
                if (!string.IsNullOrEmpty(column.DisplayFolder) && column.DisplayFolder.Contains("_direct measures")) 
                {
                    column.DisplayFolder = column.DisplayFolder.Replace("_direct measures", "_direct metrics");
                }
            }
        }
    }
}