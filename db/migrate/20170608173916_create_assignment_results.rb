class CreateAssignmentResults < ActiveRecord::Migration[5.0]
  def change
    create_table :assignment_results do |t|
      t.string :instructor
      t.string :course_prefix
      t.string :course_number
      t.string :course_title
      t.string :field_of_study
      t.string :semester
      t.float :project_length_weeks
      t.integer :students_given_assignment
      t.float :instruction_hours
      t.float :average_student_score
      t.text :outcome_summary

      ## Links to other records.
      t.integer :assignment_id
      t.integer :creator_id
      t.timestamps
    end
  end
end
