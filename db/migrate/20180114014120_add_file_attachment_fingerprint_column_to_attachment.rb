class AddFileAttachmentFingerprintColumnToAttachment < ActiveRecord::Migration[5.0]
  def change
    rename_column :attachments, :file_digest, :file_attachment_fingerprint
  end
end
