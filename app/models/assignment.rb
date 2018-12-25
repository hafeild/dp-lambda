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
  ## - instructors (users)
  ## - creator (user)

  include Bootsy::Container

  belongs_to :creator, class_name: "User"
  has_and_belongs_to_many :instructors, class_name: "User"
  belongs_to :assignment_group

  has_and_belongs_to_many :attachments


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
    [instructors.map{|i| [i.username, i.full_name].join(" ")}.join(" "), 
     course, course_prefix, course_number, course_title,
     semester, field_of_study, project_length_weeks, students_given_assignment,
     instruction_hours, outcome_summary, creator, 
     attachments.map{|a| "#{a.file_attachment_file_name} #{a.description}"}.join(" ")
    ].join(" ")
  end

  ## For search.
  searchable do
    text :notes, :learning_curve
    
    text :instructors do 
      instructors.map{|instructor| [instructor.username, instructor.full_name].join(" ")}
    end

    text :creator do 
      creator.username
    end

    text :tags do
      tags.map{|tag| tag.text}
    end

    text :assignment_group do
      [assignment_group.name, assignment_group.summary].join(" ") 
    end

    text :web_resources do
      web_resources.map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"} 
    end

    text :examples do
      examples.map{|example| "#{example.title} #{example.summary}"}
    end

    text :analyses do
      analyses.map{|a| "#{a.name} #{a.summary}"}
    end

    text :datasets do
      datasets.map{|d| "#{d.name} #{d.summary}"}
    end

    text :software do
      software.map{|s| "#{s.name} #{s.summary}"}
    end

    text :attachments do
      attachments.map{|a| "#{a.file_attachment_file_name} #{a.description}"}
    end

    ## For scoping and faceting.
    double :instruction_hours_facet do 
      instruction_hours
    end
    integer :creator_facet do 
      creator_id
    end
    string :author_facet do 
      instructors.map{|instructor| instructor.username}
    end
    string :learning_curve_facet do
      learning_curve
    end
  end

  def delink
    tags.clear
    web_resources.clear
    examples.clear
    analyses.clear
    software.clear
    datasets.clear
  end

  def delete_from_connection
    [[assignment_group], analyses, datasets, software, examples].each do |connectionSet|
      connectionSet.each do |connection|
        connection.assignments.delete(self)
        connection.save!
      end
    end
  end

  def reindex_associations
    [[assignment_group], analyses, datasets, software, examples].each do |connectionSet|
      connectionSet.each do |connection|
        connection.reload
        connection.save!
      end
    end
  end

end
