class CreatePermissionRequestsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :permission_requests do |t|
      t.string :users
      t.string :level_requested
      t.boolean :reviewed, default: false
      t.boolean :granted, default: false
      t.integer :reviewed_by
      t.datetime :reviewed_on
      
      t.timestamps
    end
  end
end
