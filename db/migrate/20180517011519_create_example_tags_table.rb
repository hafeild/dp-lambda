class CreateExampleTagsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :examples_tags do |t|
      t.integer :example_id
      t.integer :tag_id
    end
  end
end
