class AddIsDraftToWebResources < ActiveRecord::Migration[6.1]
  def change
    add_column :web_resources, :is_draft, :boolean
  end
end
