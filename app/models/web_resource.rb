class WebResource < ApplicationRecord
  ## WebResource has...
  ## - url
  ## - description
  ## - software
  ## - datasets
  ## - analyses
  ## - assignments
  ## - examples


  include Bootsy::Container
  has_and_belongs_to_many :software
  has_and_belongs_to_many :datasets
  has_and_belongs_to_many :analyses
  has_and_belongs_to_many :assignments
  has_and_belongs_to_many :examples

  ## Ensure the presence of required fields. 
  validates :url, presence: true, length: {maximum: 200}, 
    uniqueness: {case_sensitive: false}
  validates :description, presence: true, length: {maximum: 200},
    uniqueness: {case_sensitive: false}

  ## Reports the number of entries this resource is connected to.
  def belongs_to_count
    software.size + datasets.size + analyses.size + assignments.size + examples.size
  end

  ## Destroys this resource if it's connected to target_count entries.
  ## @param target_count The number of connections to consider this resource
  ##                     isolated.
  def destroy_if_isolated(target_count=0)
    if belongs_to_count == target_count
      destroy!
    end
  end
end
