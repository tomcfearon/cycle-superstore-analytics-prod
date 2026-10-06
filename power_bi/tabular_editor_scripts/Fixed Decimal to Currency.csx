int updatedCount = 0;

// Loop through every table in the model
foreach (var table in Model.Tables)
{
    // Loop through every column in the current table
    foreach (var column in table.Columns)
    {
        // Check if the data type is Fixed Decimal (Decimal in TOM)
        if (column.DataType == DataType.Decimal)
        {
            // Apply the clean Currency keyword
            column.FormatString = "Currency";
            updatedCount++;
        }
    }
}