class ChangePermissionRequestReviwedByColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :permission_requests, :reviewed_by, :reviewed_by_id
  end
end
