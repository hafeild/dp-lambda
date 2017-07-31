class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :role
      t.string :field_of_study

      t.string :password_digest
      t.string :activation_digest
      t.boolean :activated
      t.datetime :activated_at
      t.string :remember_digest
      t.string :reset_digest
      t.datetime :reset_sent_at

      t.timestamps
    end
    add_index :users, :username, unique: true
  end
end
