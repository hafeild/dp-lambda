class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.attachment :file_attachment
      t.string :file_digest
      t.integer :uploaded_by_id
      t.timestamps
    end
    
    create_join_table :attachments, :assignments
    create_join_table :attachments, :assignment_results
    create_join_table :attachments, :analyses
    create_join_table :attachments, :software
    create_join_table :attachments, :datasets
    create_join_table :attachments, :examples
    
  end
end
