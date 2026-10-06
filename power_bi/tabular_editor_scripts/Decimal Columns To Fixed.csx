int updatedCount = 0;

// Loop through every table in the model
foreach (var table in Model.Tables)
{
    // Loop through every column in the current table
    foreach (var column in table.Columns)
    {
        // Check if the data type is a standard Decimal Number (Double in TOM)
        if (column.DataType == DataType.Double)
        {
            // Change it to a Fixed Decimal Number (Decimal in TOM)
            column.DataType = DataType.Decimal;
            updatedCount++;
        }
    }
}