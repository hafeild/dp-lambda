class Example < ApplicationRecord
  ## Examples have...
  ## - title -- must be present, <= 200 chars, and unique
  ## - description -- must be present
  ## - software_id
  ## - analysis_id
  ## - dataset_id

  include Bootsy::Container
  has_and_belongs_to_many :software
  has_and_belongs_to_many :datasets

  ## Ensure the presence of required fields. 
  validates :title, presence: true, length: {maximum: 200}, 
    uniqueness: {case_sensitive: false}
  validates :description, presence: true

  ## Reports the number of entries this resource is connected to.
  def belongs_to_count
    software.size + datasets.size
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
