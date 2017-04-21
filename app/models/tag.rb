class Tag < ApplicationRecord
  has_and_belongs_to_many :software

  def belongs_to_more_than_one?
    software.size > 1
  end
end
