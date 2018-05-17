class CreateExamplesWebResources < ActiveRecord::Migration[5.0]
  def change
    create_table :examples_web_resources do |t|
      t.integer :example_id
      t.integer :web_resource_id
    end
  end
end
