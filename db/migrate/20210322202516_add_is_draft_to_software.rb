class AddIsDraftToSoftware < ActiveRecord::Migration[6.1]
  def change
    add_column :software, :is_draft, :boolean
  end
end
