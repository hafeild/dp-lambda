class AddPositionToFileAttachmentTable < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :display_position, :integer, default: 0
  end
end
