class RenameOldAssignmentTables < ActiveRecord::Migration[5.0]
  def change
    rename_table :assignments, :old_assignments
    rename_table :assignments_attachments, :old_assignments_attachments
    rename_table :assignments_assignments, :old_assignments_old_assignments
    rename_table :assignments_web_resources, :old_assignments_web_resources
    rename_table :assignments_tags, :old_assignments_tags
    rename_table :assignments_examples, :old_assignments_examples
    rename_table :assignments_software, :old_assignments_software
    rename_table :analyses_assignments, :analyses_old_assignments
    rename_table :assignments_datasets, :old_assignments_datasets
  end
end
