class ChangeUserCreatedByColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :created_by, :created_by_id 
  end
end
