class Assignment < ApplicationRecord
  ## Assignment has...
  ## - author
  ## - name
  ## - summary
  ## - description
  ## - thumbnail_url
  ## - learning_curve
  ## - instruction_hours
  ## - assignments_related_to
  ## - assignments_related_from
  ## - tags
  ## - web_resources
  ## - examples
  ## - assignment_results
  ## - creator (user)

  include Bootsy::Container

  belongs_to :creator, class_name: "User"

  has_and_belongs_to_many :assignments_related_to, class_name: 'Assignment',
    join_table: :assignments_assignments,
    foreign_key: :to_assignment_id,
    association_foreign_key: :from_assignment_id
  has_and_belongs_to_many :assignments_related_from, class_name: 'Assignment',
    join_table: :assignments_assignments,
    association_foreign_key: :from_assignment_id
    foreign_key: :to_assignment_id,

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :web_resources
  has_and_belongs_to_many :examples
  has_many :assignment_results

  ## Ensure the presence of required fields. 
  validates :name, presence: true, length: {minimum: 1, maximum: 200}, 
    uniqueness: {case_sensitive: false}
  validates :summary, presence: true, length: {minimum: 1}
  validates :description, presence: true, length: {minimum: 1}
  validates :author, presence: true, length: {minimum: 1}

  def delink
    tags.clear
    web_resources.clear
    examples.clear
  end

end
