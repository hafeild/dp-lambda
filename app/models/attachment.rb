class Attachment < ApplicationRecord
  ## Attachments have:
  ## - file_attachment_fingerprint (hash of file contents)
  ## - uploaded_by (user who uploaded it)
  ## - created_at
  ## - updated_at
  ## - description
  ## - display_position
  ## - file_attachment (A paperclip object)
  ##   * file_name
  ##   * file_size
  ##   * content_type
  ##   * updated_at

  belongs_to :uploaded_by, class_name: "User"
  has_attached_file :file_attachment

  validates_attachment :file_attachment, presence: true,
    size: { in: 0..Rails.configuration.MAX_ATTACHMENT_SIZE }
  
  ## We may want to replace this with a list of accepted attachment types.
  do_not_validate_attachment_file_type :file_attachment
  
  has_and_belongs_to_many :assignment
  has_and_belongs_to_many :analysis
  has_and_belongs_to_many :software
  has_and_belongs_to_many :example
end