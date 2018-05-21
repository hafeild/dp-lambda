class CreateAnalysesSoftwareTable < ActiveRecord::Migration[5.0]
  def change
    create_table :analyses_software do |t|
      t.integer :analysis_id
      t.integer :software_id
    end
  end
end
