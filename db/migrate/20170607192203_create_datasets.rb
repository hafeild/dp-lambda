class CreateDatasets < ActiveRecord::Migration[5.0]
  def change
    create_table :datasets do |t|
      t.string :name
      t.text :summary
      t.text :description
      t.string :thumbnail_url
      t.integer :creator_id

      t.timestamps
    end

    create_table :datasets_web_resources do |t|
      t.integer :dataset_id
      t.integer :web_resource_id
    end

    create_table :datasets_tags do |t|
      t.integer :dataset_id
      t.integer :tag_id
    end

    create_table :datasets_examples do |t|
      t.integer :dataset_id
      t.integer :example_id
    end
  end
end
