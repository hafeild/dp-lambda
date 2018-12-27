class CreateNewAssignmentTables < ActiveRecord::Migration[5.0]
  def change
    ## The new AssignmentGroup model.
    create_table :assignment_groups do |t|
      #t.integer :author_id
      t.string :name
      t.text :summary
      t.text :description
      t.string :thumbnail_url
      t.integer :creator_id
      t.timestamps
    end

    ## The new Assignment model.
    create_table :assignments do |t|
      t.string :notes
      #t.string :instructor
      t.string :course_prefix
      t.string :course_number
      t.string :course_title
      t.string :field_of_study
      t.string :semester
      t.string :learning_curve
      t.float :project_length_weeks
      t.integer :students_given_assignment
      t.float :instruction_hours
      t.float :average_student_score
      t.text :outcome_summary

      ## Links to other records.
      t.integer :assignment_group_id
      t.integer :creator_id
      t.timestamps
    end

    ## Links between AssignmentGroups and users & resources.
    create_join_table :assignment_groups, :users, table_name: :assignment_groups_authors
    create_join_table :assignment_groups, :tags
    create_join_table :assignment_groups, :web_resources

    ## Links between Assignments and other verticals & resources.
    create_join_table :assignments, :users, table_name: :assignments_instructors
    create_join_table :assignments, :tags
    create_join_table :assignments, :web_resources
    create_join_table :assignments, :assignments
    create_join_table :assignments, :software
    create_join_table :assignments, :analyses
    create_join_table :assignments, :datasets
    create_join_table :assignments, :examples
    create_join_table :assignments, :attachments

    ## Update the User table to handle unregistered users being added
    ## as authors and instructors to verticals.
    add_column :users, :is_registered, :boolean
    add_column :users, :created_by, :integer
  end
end
