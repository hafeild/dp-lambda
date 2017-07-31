class CreateAnalyses < ActiveRecord::Migration[5.0]
  def change
    create_table :analyses do |t|
      t.string :name
      t.text :summary
      t.text :description
      t.string :thumbnail_url
      t.integer :creator_id

      t.timestamps
    end

    create_table :analyses_web_resources do |t|
      t.integer :analysis_id
      t.integer :web_resource_id
    end

    create_table :analyses_tags do |t|
      t.integer :analysis_id
      t.integer :tag_id
    end

    create_table :analyses_examples do |t|
      t.integer :analysis_id
      t.integer :example_id
    end
  end
end
