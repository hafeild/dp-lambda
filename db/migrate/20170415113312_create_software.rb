class CreateSoftware < ActiveRecord::Migration[5.0]
  def change
    create_table :software do |t|
      t.string :name
      t.text :summary
      t.text :description
      t.string :thumbnail_url
      t.integer :creator_id

      t.timestamps
    end

    create_table :software_web_resources do |t|
      t.integer :software_id
      t.integer :web_resource_id
      t.timestamps
    end

    create_table :software_tags do |t|
      t.integer :software_id
      t.integer :tag_id
      t.timestamps
    end

    create_table :examples_software do |t|
      t.integer :software_id
      t.integer :example_id
      t.timestamps
    end
  end
end
