class AddPermissionLevelToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :permission_level, :string, default: 'viewer'
    add_column :users, :permission_level_granted_on, :datetime
    add_column :users, :permission_level_granted_by, :integer
    remove_column :users, :can_edit, :boolean
    remove_column :users, :is_admin, :boolean
  end
end
