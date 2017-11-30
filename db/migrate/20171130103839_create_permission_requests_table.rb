class CreatePermissionRequestsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :permission_requests_tables do |t|
      t.string :users
      t.string :level_requested
      t.boolean :reviewed
      t.boolean :granted
      t.integer :reviewed_by
      t.datetime :reviewed_on
    end
  end
end
