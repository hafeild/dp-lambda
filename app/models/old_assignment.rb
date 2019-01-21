class OldAssignment < ApplicationRecord
  ## OldAssignment has...
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
  ## - software
  ## - analyses
  ## - datasets
  ## - creator (user)
  ## - attachments

  include Bootsy::Container

  ## Destroys all assignment results when destroyed.
  before_destroy :destroy_assignment_results
  #after_destroy :reload_connections

  belongs_to :creator, class_name: "User"

  has_and_belongs_to_many :assignments_related_to, class_name: 'OldAssignment',
    join_table: :assignments_assignments,
    foreign_key: :to_assignment_id,
    association_foreign_key: :from_assignment_id
  has_and_belongs_to_many :assignments_related_from, class_name: 'OldAssignment',
    join_table: :assignments_assignments,
    foreign_key: :from_assignment_id,
    association_foreign_key: :to_assignment_id

    has_and_belongs_to_many :tags, class_name: 'Tag', join_table: :old_assignments_tags, foreign_key: :tag_id, association_foreign_key: :assignment_id

    has_and_belongs_to_many :web_resources, class_name: 'WebResource', join_table: :old_assignments_web_resources, foreign_key: :web_resource_id, association_foreign_key: :assignment_id

    has_and_belongs_to_many :examples, class_name: 'Example', join_table: :old_assignments_examples, foreign_key: :example_id, association_foreign_key: :assignment_id
    has_and_belongs_to_many :software, class_name: 'Software', join_table: :old_assignments_software, foreign_key: :software_id, association_foreign_key: :assignment_id
    has_and_belongs_to_many :analyses, class_name: 'Analysis', join_table: :analyses_old_assignments, foreign_key: :analysis_id, association_foreign_key: :assignment_id
    has_and_belongs_to_many :datasets, class_name: 'Dataset', join_table: :old_assignments_datasets, foreign_key: :dataset_id, association_foreign_key: :assignment_id
    has_and_belongs_to_many :attachments, class_name: 'Attachment', join_table: :old_assignments_attachments, foreign_key: :attachment_id, association_foreign_key: :assignment_id

    has_many :assignment_results, foreign_key: :assignment_id

  # has_and_belongs_to_many :tags
  # has_and_belongs_to_many :web_resources
  # has_and_belongs_to_many :examples
  # has_and_belongs_to_many :software
  # has_and_belongs_to_many :analyses
  # has_and_belongs_to_many :datasets
  # has_many :assignment_results
  # has_and_belongs_to_many :attachments

  ## Ensure the presence of required fields. 
  validates :name, presence: true, length: {minimum: 1, maximum: 200}, 
    uniqueness: {case_sensitive: false}
  validates :summary, presence: true, length: {minimum: 1}
  #validates :description, presence: true, length: {minimum: 1}
  validates :author, presence: true, length: {minimum: 1}

  def related_assignments
    (assignments_related_to + assignments_related_from).uniq
  end

  ## For search.
  # searchable do
  #   text :author, :name, :summary, :description, :learning_curve
    
  #   text :creator do 
  #     creator.username
  #   end

  #   text :tags do
  #     tags.map{|tag| tag.text}
  #   end

  #   text :assignment_results do
  #     assignment_results.map{ |res| res.to_s}
  #   end

  #   text :assignments do
  #     related_assignments.map{|a| "#{a.name} #{a.summary}"} 
  #   end

  #   text :web_resources do
  #     web_resources.map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"} 
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
  #   string :author_facet do 
  #     author
  #   end
  #   string :learning_curve_facet do
  #     learning_curve
  #   end

  # end

  def delink
    tags.clear
    web_resources.clear
    examples.clear
  end

  def delete_from_connection
    [assignments_related_to, assignments_related_from, analyses, datasets, software, examples].each do |connectionSet|
      connectionSet.each do |connection|
        if connection.class == OldAssignment
          connection.assignments_related_from.delete(self)
          connection.assignments_related_to.delete(self)
        else
          connection.assignments.delete(self)
        end
        connection.save!
      end
    end
  end

  def reindex_associations
    [assignments_related_to, assignments_related_from, analyses, datasets, software, examples].each do |connectionSet|
      connectionSet.each do |connection|
        connection.reload
        connection.save!
      end
    end
  end

  private
    def destroy_assignment_results
      assignment_results.each do |assignment_result|
        assignment_result.destroy!
      end
    end
end
