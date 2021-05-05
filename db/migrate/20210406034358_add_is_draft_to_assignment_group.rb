class AddIsDraftToAssignmentGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :assignment_groups, :is_draft, :boolean
  end
end
