class AssignmentResult < ApplicationRecord
  ## AssignmentResult has...
  ## - assignment
  ## - instructor
  ## - course
  ## - course_prefix
  ## - course_number
  ## - field_of_study
  ## - project_length_weeks
  ## - students_given_assignment
  ## - instruction_hours
  ## - average_student_score
  ## - outcome_summary
  ## - creator (user)

  include Bootsy::Container

  belongs_to :creator, class_name: "User"
  belongs_to :assignment

  ## Ensure the presence of required fields. 
  validates :instructor, presence: true, length: {minimum: 1, maximum: 200}
  validates :course_prefix, presence: true, length: {minimum: 1, maximum: 3}
  validates :course_number, presence: true, length: {minimum: 1, maximum: 3}
  validates :field_of_study, presence: true, length: {minimum: 1, maximum: 200}

  validates :summary, presence: true
  validates :description, presence: true

  def course
    "#{:course_prefix}#{:course_number}"
  end

end
