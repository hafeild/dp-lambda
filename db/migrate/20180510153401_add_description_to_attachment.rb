class AddDescriptionToAttachment < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :description, :string, default: ''
  end
end
