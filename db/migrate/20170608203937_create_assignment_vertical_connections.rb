class CreateAssignmentVerticalConnections < ActiveRecord::Migration[5.0]
  def change
    create_join_table :assignments, :software
    create_join_table :assignments, :analyses
    create_join_table :assignments, :datasets
  end
end
