class Software < ApplicationRecord
  ## Software has...
  ## - name
  ## - summary
  ## - description
  ## - thumbnail_url
  ## - creator (user)
  ## - tags
  ## - web_resources
  ## - examples

  belongs_to :creator, class_name: "User"
  has_and_belongs_to_many :tags
  has_and_belongs_to_many :web_resources
  has_and_belongs_to_many :examples, through: :software_examples


end
