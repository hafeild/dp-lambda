class AddIsDraftToAnalyses < ActiveRecord::Migration[6.1]
  def change
    add_column :analyses, :is_draft, :boolean
  end
end
