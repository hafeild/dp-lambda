class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments do |t|
      t.string :author
      t.string :name
      t.text :summary
      t.text :description
      t.string :thumbnail_url
      t.string :learning_curve
      t.float :instruction_hours
      t.integer :creator_id
      t.timestamps
    end

    create_table :assignments_assignments do |t|
      t.integer :from_assignment_id
      t.integer :to_assignment_id
    end

    create_table :assignments_web_resources do |t|
      t.integer :assignment_id
      t.integer :web_resource_id
    end

    create_table :assignments_tags do |t|
      t.integer :assignment_id
      t.integer :tag_id
    end

    create_table :assignments_examples do |t|
      t.integer :assignment_id
      t.integer :example_id
    end
  end
end
