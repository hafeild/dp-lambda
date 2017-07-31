class CreateExamples < ActiveRecord::Migration[5.0]
  def change
    create_table :examples do |t|
      t.integer :dataset_id
      t.integer :software_id
      t.integer :analysis_id
      t.string :title
      t.text :description
      t.timestamps
    end
  end
end
