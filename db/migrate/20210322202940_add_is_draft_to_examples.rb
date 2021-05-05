class AddIsDraftToExamples < ActiveRecord::Migration[6.1]
  def change
    add_column :examples, :is_draft, :boolean
  end
end
