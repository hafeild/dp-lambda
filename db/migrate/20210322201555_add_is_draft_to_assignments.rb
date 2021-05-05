class AddIsDraftToAssignments < ActiveRecord::Migration[6.1]
  def change
    add_column :assignments, :is_draft, :boolean
  end
end
