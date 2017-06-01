class Tag < ApplicationRecord
  has_and_belongs_to_many :software

  ## Reports the number of entries this resource is connected to.
  def belongs_to_count
    software.size
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
end
