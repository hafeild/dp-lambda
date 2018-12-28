class Tag < ApplicationRecord
  ## Tag has...
  ## - text
  ## - software
  ## - datasets
  ## - analyses
  ## - assignments
  ## - assignment_groups
  ## - examples
  ## - created_at
  ## - updated_at

  has_and_belongs_to_many :software
  has_and_belongs_to_many :datasets
  has_and_belongs_to_many :analyses
  has_and_belongs_to_many :assignments
  has_and_belongs_to_many :assignment_groups
  has_and_belongs_to_many :examples

  after_destroy :reload_connections

  ## Reports the number of entries this resource is connected to.
  def belongs_to_count
    software.size + datasets.size + analyses.size + assignments.size + examples.size
  end

  ## Ensure the presence of required fields. 
  validates :text, presence: true, length: {maximum: 200, minimum: 1}, 
    uniqueness: {case_sensitive: false}

  ## Destroys this resource if it's connected to target_count entries.
  ## @param target_count The number of connections to consider this resource
  ##                     isolated.
  def destroy_if_isolated(target_count=0)
    if belongs_to_count == target_count
      destroy!
    end
  end


  private
    def reload_connections
      [assignment_groups, assignments, analyses, datasets, 
       software, examples].each do |connectionSet|
        connectionSet.each do |connection|
          connection.tags.delete(self)
          connection.save!
        end
      end
    end

end
