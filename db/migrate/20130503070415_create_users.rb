class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, limit: 255
      t.string :roman_name, limit: 255
      t.string :password_digest, limit: 255 
      t.string :email, limit: 255
      t.integer :company_id, limit: 11
      t.integer :role_id, limit: 11
      t.column :password_flg, "char(1)", default: "1"
      t.column :status, "char(1)", default: "0"
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11

      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
    add_index :users, :roman_name, unique: true
  end
end
