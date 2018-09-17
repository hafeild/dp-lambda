class AddDeletedToUsersTable < ActiveRecord::Migration[5.0]
  def change
	add_column :users, :deleted, :boolean
  end
end
