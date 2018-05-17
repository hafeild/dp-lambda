class Example < ApplicationRecord
  ## Examples have...
  ## - title -- must be present, <= 200 chars, and unique
  ## - summary
  ## - description -- must be present
  ## - software
  ## - analyses
  ## - datasets
  ## - tags
  ## - web_resources

  include Bootsy::Container
  has_and_belongs_to_many :software
  has_and_belongs_to_many :datasets
  has_and_belongs_to_many :analyses
  has_and_belongs_to_many :assignments
  has_and_belongs_to_many :attachments
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :web_resources
  belongs_to :creator, class_name: "User"

  ## Ensure the presence of required fields. 
  validates :title, presence: true, length: {maximum: 200}, 
    uniqueness: {case_sensitive: false}
  validates :description, presence: true

  ## Reports the number of entries this resource is connected to.
  def belongs_to_count
    software.size + datasets.size + analyses.size + assignments.size + tags.size + web_resources.size
  end

  ## Destroys this resource if it's connected to target_count entries.
  ## @param target_count The number of connections to consider this resource
  ##                     isolated.
  # def destroy_if_isolated(target_count=0)
  #   if belongs_to_count == target_count
  #     destroy!
  #   end
  # end
end
