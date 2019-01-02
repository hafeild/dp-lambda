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
  has_and_belongs_to_many :instructors, class_name: "User", join_table: "assignments_instructors"
  belongs_to :assignment_group

  has_and_belongs_to_many :attachments

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :web_resources
  has_and_belongs_to_many :examples
  has_and_belongs_to_many :software
  has_and_belongs_to_many :analyses
  has_and_belongs_to_many :datasets

  has_and_belongs_to_many :assignments_related_to, class_name: 'Assignment',
    join_table: :assignments_assignments,
    foreign_key: :to_assignment_id,
    association_foreign_key: :from_assignment_id
  has_and_belongs_to_many :assignments_related_from, class_name: 'Assignment',
    join_table: :assignments_assignments,
    foreign_key: :from_assignment_id,
    association_foreign_key: :to_assignment_id

  ## Ensure the presence of required fields. 
  validates :assignment_group, presence: true
  validates :instructors, presence: true, length: {minimum: 1}
  validates :course_prefix, presence: true, length: {minimum: 1, maximum: 3}
  validates :course_number, presence: true, length: {minimum: 1, maximum: 3}
  validates :course_title, presence: true, length: {minimum: 1, maximum: 200}
  validates :field_of_study, presence: true, length: {minimum: 1, maximum: 200}
  validates :semester, presence: true, length: {minimum: 1, maximum: 15}

  def course
    "#{course_prefix}#{course_number}"
  end

  def related_assignments
    (assignments_related_to + assignments_related_from).uniq
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

    text :authors do 
      assignment_group.authors.map{|author| [author.username, author.full_name].join(" ")}
    end

    text :creator do 
      creator.username
    end

    text :tags do
      (tags + assignment_group.tags).map{|tag| tag.text}.uniq
    end

    text :name do 
      assignment_group.name
    end

    text :summary do
      assignment_group.summary
    end

    text :description do
      assignment_group.description
    end

    # text :assignment_group do
    #   [assignment_group.name, assignment_group.summary].join(" ") 
    # end


    text :web_resources do
      (web_resources + assignment_group.web_resources).map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"} 
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
    string :instructor_facet do 
      instructors.map{|instructor| instructor.username}.join(" ")
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
    [[assignment_group], assignments_related_to, assignments_related_from,analyses, datasets, software, examples].each do |connectionSet|
      connectionSet.each do |connection|
        connection.assignments.delete(self)
        connection.save!
      end
    end
  end

  def reindex_associations
    [[assignment_group], assignments_related_to, assignments_related_from,analyses, datasets, software, examples].each do |connectionSet|
      connectionSet.each do |connection|
        connection.reload
        connection.save!
      end
    end
  end

end
