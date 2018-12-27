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
  #validates :author, presence: true, length: {minimum: 1}

  def related_assignments
    (assignments_related_to + assignments_related_from).uniq
  end

  ## For search.
  searchable do
    text :name, :summary, :description
    
    text :creator do 
      creator.username
    end

    text :authors do 
      authors.map{|author| [author.username, author.full_name].join(" ")}
    end

    text :tags do
      tags.map{|tag| tag.text}
    end

    text :web_resources do
      web_resources.map{|wr| "#{wr.url.gsub('/', ' ')} #{wr.description}"} 
    end

    text :assignments do
      assignments.map{ |a| a.to_s}
    end


    ## For scoping and faceting.
    integer :creator_facet do 
      creator_id
    end
    string :author_facet do 
      authors.map{|author| [author.username, author.full_name].join(" ")}.join(" ")
    end


  end

  def delink
    tags.clear
    web_resources.clear
  end

  private
    def destroy_assignment_results
      assignments.each do |assignment|
        assignment.destroy!
      end
    end
end
