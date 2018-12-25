class Assignment < ApplicationRecord
  ## Assignment has...
  ## - assignment_group
  ## - notes
  ## - course
  ## - course_prefix
  ## - course_number
  ## - course_title
  ## - semester
  ## - learning_curve
  ## - field_of_study
  ## - project_length_weeks
  ## - students_given_assignment
  ## - instruction_hours
  ## - average_student_score
  ## - outcome_summary
  ## - attachements
  ## - thumbnail
  ## - instructors (user)
  ## - creator (user)

  include Bootsy::Container

  belongs_to :creator, class_name: "User"
  has_and_belongs_to_many :instructors, class_name: "User"
  belongs_to :assignment_group

  ## Ensure the presence of required fields. 
  # validates :instructor, presence: true, length: {minimum: 1, maximum: 200}
  validates :course_prefix, presence: true, length: {minimum: 1, maximum: 3}
  validates :course_number, presence: true, length: {minimum: 1, maximum: 3}
  validates :course_title, presence: true, length: {minimum: 1, maximum: 200}
  validates :field_of_study, presence: true, length: {minimum: 1, maximum: 200}
  validates :semester, presence: true, length: {minimum: 1, maximum: 15}

  def course
    "#{:course_prefix}#{:course_number}"
  end

  def to_s
    [instructor, course, course_prefix, course_number, course_title,
     semester, field_of_study, project_length_weeks, students_given_assignment,
     instruction_hours, average_student_score, outcome_summary, creator
    ].join(" ")
  end

end
