class AssignmentGroup < ApplicationRecord
  ## AssignmentGroup has...
  ## - name
  ## - summary
  ## - description
  ## - thumbnail_url
  ## - tags
  ## - web_resources
  ## - authors (users)
  ## - creator (user)
  ##
  ## Derived from assignments within the group:
  ## - examples
  ## - assignment_results
  ## - software
  ## - analyses
  ## - datasets

  include Bootsy::Container
  mount_uploader :thumbnail, ThumbnailUploader
  attr_accessor :tumbnail_cache

  ## Destroys all assignments when destroyed.
  before_destroy :destroy_assignments
  #after_destroy :reload_connections

  belongs_to :creator, class_name: "User"
  has_and_belongs_to_many :authors, class_name: "User", join_table: "assignment_groups_authors"

  has_many :assignments

  has_and_belongs_to_many :tags
  has_and_belongs_to_many :web_resources
  

  ## Ensure the presence of required fields. 
  validates :name, presence: true, length: {minimum: 1, maximum: 200}, 
    uniqueness: {case_sensitive: false}
  validates :summary, presence: true, length: {minimum: 1}

  #validates :description, presence: true, length: {minimum: 1}
  validates :authors, presence: true, length: {minimum: 1}

  def author_ids_csv
    authors.map{|a| a.id}.join(",")
  end

  ## ! For now, assignment groups cannot be searched.
  ## For search.
  searchable do
    # all_tags = tags.map{|tag| tag.text}
    # all_web_resources = web_resources.map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"}
    # all_learning_curves = []
    # all_instructors = []
    # all_creators = ["#{creator.username} #{creator.full_name}"]
    # all_notes = []
    # all_examples = []
    # all_software = []
    # all_analyses = []
    # all_datasets = []
    # all_attachements = []
    # all_general = []

    # assignments.each do |a|
    #   all_tags += a.tags.map{|tag| tag.text}
    #   all_web_resources += a.web_resources.map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"}
    #   all_notes << a.notes
    #   all_learning_curves << a.learning_curve
    #   all_instructors += a.instructors.map{|i| "#{i.full_name} #{i.username}"}
    #   all_creators += a.creators.map{|c| "#{c.full_name} #{c.username}"}
    #   all_examples += a.examples.map{|example| "#{example.title} #{example.summary}"}
    #   all_software += a.software.map{|s| "#{s.name} #{s.summary}"}
    #   all_analyses += a.analyses.map{|a| "#{a.name} #{a.summary}"}
    #   all_datasets += a.datasets.map{|d| "#{d.name} #{d.summary}"}
    #   all_attachments += a.attachments.map{|a| "#{a.file_attachment_file_name} #{a.description}"}
    #   all_general << a.to_s
    # end


    text :name, :summary, :description
    
    text :creator do 
      # all_creator
      (["#{creator.username} #{creator.full_name}"] + 
        assignments.map{|a| "#{a.creator.full_name} #{a.creator.username}"}).flatten
    end

    text :authors do 
      authors.map{|author| [author.username, author.full_name].join(" ")}.join(" ")
    end

    text :tags do
      # all_tags
      tags.map{|t| t.text} + assignments.map{|a| a.tags.map{|tag| tag.text}}.flatten
    end

    text :web_resources do
      ([ web_resources.map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"}] + 
        assignments.map{|a| a.web_resources.map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"}}).flatten
    end

    text :general do
      # all_general
      assignments.map{|a| a.to_s}
    end

    text :notes do 
      # all_notes
      assignments.map{|a| a.notes}
    end
    
    text :learning_curve do 
      # all_learning_curves 
      assignments.map{|a| a.learning_curve}
    end
    
    text :instructors do 
      # all_instructors
      assignments.map{|a| a.instructors.map{|i| "#{i.full_name} #{i.username}"}}.flatten
    end

    text :examples do
      # all_examples
      assignments.map{|a| a.examples.map{|e| "#{e.title} #{e.summary}"}}.flatten
    end

    text :analyses do
      # all_analyses
      assignments.map{|a| a.analyses.map{|a| "#{a.name} #{a.summary}"}}.flatten
    end

    text :datasets do
    #   all_datasets
      assignments.map{|a| a.datasets.map{|d| "#{d.name} #{d.summary}"}}.flatten
    end

    text :software do
      # all_software
      assignments.map{|a| a.software.map{|s| "#{s.name} #{s.summary}"}}.flatten
    end

    text :attachments do
      # all_attachments
      assignments.map{|a| a.attachments.map{|at| "#{at.file_attachment_file_name} #{at.description}"}}.flatten
    end


    # text :assignments do
    #   assignments.map{ |a| a.to_s}
    # end

    ## For scoping and faceting.
    # integer :creator_facet do 
    #   creator_id
    # end
    # string :author_facet do 
    #   authors.map{|author| [author.username, author.full_name].join(" ")}.join(" ")
    # end


  end

  def delink
    tags.clear
    web_resources.clear
  end

  def reindex_associations
    assignments.each do |assignment|
      assignment.reload
      assignment.save!
      assignment.reindex_associations
    end
  end

  private
    def destroy_assignments
      assignments.each do |assignment|
        ApplicationController.helpers.destroy_isolated_resources(assignment)
        assignment.destroy!
      end
    end
end
