// =============================================================================
// Set Primary Keys as Key Columns & Hide Foreign Keys
// =============================================================================
// Iterates every active relationship in the model:
//
//   • ToColumn   (the "one" / unique side) → IsKey = true
//   • FromColumn (the "many" / FK side)    → IsHidden = true
//
// Duplicates are eliminated — a column used in multiple relationships is only
// listed and changed once. A scrollable dialog previews changes before applying.
// =============================================================================

// Deduplicate by column identity — a column used in multiple relationships
// should only appear once in the preview and be changed once.
// Use object-typed HashSet so TE2's TOMWrapper columns compare by reference.
var pkCols = new System.Collections.Generic.HashSet<object>();
var fkCols = new System.Collections.Generic.HashSet<object>();

foreach (var rel in Model.Relationships)
{
    if (!rel.ToColumn.IsKey)      pkCols.Add(rel.ToColumn);
    if (!rel.FromColumn.IsHidden) fkCols.Add(rel.FromColumn);
}

if (!pkCols.Any() && !fkCols.Any())
{
    Info("Nothing to do — all primary keys are already marked as key columns "
       + "and all foreign keys are already hidden.");
    return;
}

// ── Build preview text ────────────────────────────────────────────────────────
var preview = new System.Text.StringBuilder();

if (pkCols.Any())
{
    preview.AppendLine("Primary keys to mark as key columns (" + pkCols.Count + "):");
    foreach (Column c in pkCols.Cast<Column>().OrderBy(c => c.Table.Name).ThenBy(c => c.Name))
        preview.AppendLine("  " + c.Table.Name + "[" + c.Name + "]");
}

if (fkCols.Any())
{
    if (pkCols.Any()) preview.AppendLine();
    preview.AppendLine("Foreign keys to hide (" + fkCols.Count + "):");
    foreach (Column c in fkCols.Cast<Column>().OrderBy(c => c.Table.Name).ThenBy(c => c.Name))
        preview.AppendLine("  " + c.Table.Name + "[" + c.Name + "]");
}

// ── Scrollable confirmation dialog ───────────────────────────────────────────
var form = new System.Windows.Forms.Form();
form.Text = "Set PKs + Hide FKs";
form.Width = 520;
form.Height = 500;
form.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
form.FormBorderStyle = System.Windows.Forms.FormBorderStyle.Sizable;

var txt = new System.Windows.Forms.RichTextBox();
txt.Dock = System.Windows.Forms.DockStyle.Fill;
txt.ReadOnly = true;
txt.Text = preview.ToString().TrimEnd() + "\n\nApply all changes?";
txt.ScrollBars = System.Windows.Forms.RichTextBoxScrollBars.Vertical;

var panel = new System.Windows.Forms.Panel();
panel.Dock = System.Windows.Forms.DockStyle.Bottom;
panel.Height = 44;

var btnYes = new System.Windows.Forms.Button();
btnYes.Text = "Yes";
btnYes.Width = 80;
btnYes.Height = 28;
btnYes.Left = 340;
btnYes.Top = 8;
btnYes.DialogResult = System.Windows.Forms.DialogResult.Yes;

var btnNo = new System.Windows.Forms.Button();
btnNo.Text = "No";
btnNo.Width = 80;
btnNo.Height = 28;
btnNo.Left = 428;
btnNo.Top = 8;
btnNo.DialogResult = System.Windows.Forms.DialogResult.No;

panel.Controls.Add(btnYes);
panel.Controls.Add(btnNo);
form.Controls.Add(txt);
form.Controls.Add(panel);
form.AcceptButton = btnYes;
form.CancelButton = btnNo;

var answer = form.ShowDialog();

if (answer != System.Windows.Forms.DialogResult.Yes)
{
    Info("Cancelled — no changes made.");
    return;
}

// ── Apply ─────────────────────────────────────────────────────────────────────
foreach (Column c in pkCols.Cast<Column>()) c.IsKey    = true;
foreach (Column c in fkCols.Cast<Column>()) c.IsHidden = true;

Info(
    "Done!\n\n"
  + "  • " + pkCols.Count + " primary key column(s) marked as key columns.\n"
  + "  • " + fkCols.Count + " foreign key column(s) hidden."
);
