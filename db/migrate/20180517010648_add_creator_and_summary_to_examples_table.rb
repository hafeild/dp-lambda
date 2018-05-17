class AddCreatorAndSummaryToExamplesTable < ActiveRecord::Migration[5.0]
  def change
      add_column :examples, :creator_id, :integer
      add_column :examples, :summary, :string
  end
end
