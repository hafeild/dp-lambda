class AddPermissionsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :can_edit, :boolean
    add_column :users, :is_admin, :boolean
  end
end
