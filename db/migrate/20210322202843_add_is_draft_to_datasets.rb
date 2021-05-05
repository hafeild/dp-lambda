class AddIsDraftToDatasets < ActiveRecord::Migration[6.1]
  def change
    add_column :datasets, :is_draft, :boolean
  end
end
