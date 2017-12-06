class ChangeUserPermissionLevelGrantedByColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :permission_level_granted_by, 
      :permission_level_granted_by_id

  end
end
