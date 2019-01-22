class Assignment < ApplicationRecord
  ## Assignment has...
  ## - assignment_group
  ## - name (alias for assignment_group.name)
  ## - summary (alias for assignment_group.summary)
  ## - description (alias for assignment_group.description)
  ## - authors (users) (alias for assignment_group.authors)
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

  after_save :reindex_assignment_group

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

  ## Aliases for assignment group fields.
  def description
    assignment_group.description
  end

  def summary
    assignment_group.summary
  end

  def name
    assignment_group.name
  end

  def authors
    assignment_group.authors
  end
  #### End aliases

  def instructor_ids_csv
    instructors.map{|i| i.id}.join(",")
  end

  def course
    "#{course_prefix}#{course_number}"
  end

  def full_title
    "#{course}—#{course_title}"
  end

  def full_title_with_semester
    "#{full_title} (#{semester})"
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

  ## Copies everything, including associations.
  def deep_clone
    # a = clone

    a = Assignment.new
    a.assignment_group = assignment_group
    a.notes = notes
    a.course_prefix = course_prefix
    a.course_number = course_number
    a.course_title = course_title
    a.semester = semester
    a.learning_curve = learning_curve
    a.field_of_study = field_of_study
    a.project_length_weeks = project_length_weeks
    a.students_given_assignment = students_given_assignment
    a.instruction_hours = instruction_hours
    a.average_student_score = average_student_score
    a.outcome_summary = outcome_summary
    a.creator = creator

    
    # ## Clone associations.
    #a.instructors = instructors 
    # a.tags = tags 
    # a.web_resources = web_resources
    # a.examples = examples
    # a.software = software
    # a.analyses = analyses
    # a.datasets = datasets
    # a.assignments_related_to = assignments_related_to
    # a.assignments_related_from = assignments_related_from

    instructors.each{|i| a.instructors << i}
    tags.each{|i| a.tags << i}
    web_resources.each{|i| a.web_resources << i}
    examples.each{|i| a.examples << i}
    software.each{|i| a.software << i}
    analyses.each{|i| a.analyses << i}
    datasets.each{|i| a.datasets << i}

    assignments_related_from.each{|i| a.assignments_related_from << i}
    assignments_related_to.each{|i| a.assignments_related_to << i}

    ## Requires copies to be made.
    attachments.each do |attachment|
      attachment_copy = attachment.clone
      attachment_copy.save!
      a.attachments << attachment_copy
    end

    a
  end

  # ## For search.
  # searchable do
  #   text :notes, :learning_curve
    
  #   text :instructors do 
  #     instructors.map{|instructor| [instructor.username, instructor.full_name].join(" ")}
  #   end

  #   text :authors do 
  #     assignment_group.authors.map{|author| [author.username, author.full_name].join(" ")}
  #   end

  #   text :creator do 
  #     creator.username
  #   end

  #   text :tags do
  #     (tags + assignment_group.tags).map{|tag| tag.text}.uniq
  #   end

  #   text :name do 
  #     assignment_group.name
  #   end

  #   text :summary do
  #     assignment_group.summary
  #   end

  #   text :description do
  #     assignment_group.description
  #   end

  #   # text :assignment_group do
  #   #   [assignment_group.name, assignment_group.summary].join(" ") 
  #   # end


  #   text :web_resources do
  #     (web_resources + assignment_group.web_resources).map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"} 
  #   end

  #   text :examples do
  #     examples.map{|example| "#{example.title} #{example.summary}"}
  #   end

  #   text :analyses do
  #     analyses.map{|a| "#{a.name} #{a.summary}"}
  #   end

  #   text :datasets do
  #     datasets.map{|d| "#{d.name} #{d.summary}"}
  #   end

  #   text :software do
  #     software.map{|s| "#{s.name} #{s.summary}"}
  #   end

  #   text :attachments do
  #     attachments.map{|a| "#{a.file_attachment_file_name} #{a.description}"}
  #   end

  #   ## For scoping and faceting.
  #   double :instruction_hours_facet do 
  #     instruction_hours
  #   end
  #   integer :creator_facet do 
  #     creator_id
  #   end
  #   string :instructor_facet do 
  #     instructors.map{|instructor| instructor.username}.join(" ")
  #   end
  #   string :learning_curve_facet do
  #     learning_curve
  #   end
  # end

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

      #assignments_related_to, assignments_related_from
    end
  end

  def reindex_associations
    [[assignment_group], analyses, datasets, software, examples].each do |connectionSet|
      connectionSet.each do |connection|
        connection.reload
        connection.save!
      end
      # assignments_related_to, assignments_related_from,
    end
  end

  def reindex_assignment_group
    assignment_group.reload
    assignment_group.save!
    # Sunspot.index(assignment_group)
  end

end
