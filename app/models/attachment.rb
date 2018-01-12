class Attachment < ApplicationRecord
  ## Attachments have:
  ## - file_digest (hash of file contents)
  ## - uploaded_by (user who uploaded it)
  ## - created_at
  ## - updated_at
  ## - file_attachment (A paperclip object)
  ##   * file_name
  ##   * file_size
  ##   * content_type
  ##   * updated_at

  belongs_to :uploaded_by, class_name: "User"
  has_attached_file :file_attachment

  validates_attachment :file_attachment, presence: true,
    size: { in: 0..5.megabytes }
    
  
end