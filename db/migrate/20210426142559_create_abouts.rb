class CreateAbouts < ActiveRecord::Migration[6.1]
  def change
    create_table :abouts do |t|
      t.text :about_summary
      t.text :purpose
      t.text :contributers

      t.timestamps
    end
  end
end
