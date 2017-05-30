class WebResource < ApplicationRecord
  ## WebResource has...
  ## - url
  ## - description

  include Bootsy::Container
  has_and_belongs_to_many :software

  ## Reports the number of entries this resource is connected to.
  def belongs_to_count
    software.size
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
