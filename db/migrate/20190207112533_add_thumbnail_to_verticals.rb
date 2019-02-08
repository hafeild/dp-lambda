class AddThumbnailToVerticals < ActiveRecord::Migration[5.0]
  def change
    rename_column :analyses, :thumbnail_url, :thumbnail
    rename_column :assignment_groups, :thumbnail_url, :thumbnail
    rename_column :datasets, :thumbnail_url, :thumbnail 
    rename_column :software, :thumbnail_url, :thumbnail

    add_column :examples, :thumbnail, :string 
  end
end
