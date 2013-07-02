class CreateClientUsers < ActiveRecord::Migration
  def change
    create_table :client_users do |t|
      t.integer :client_id, limit: 11
      t.integer :user_id, limit: 11
      t.column :del_flg, "char(1)", default: "0"

      t.timestamps
    end
    add_index :client_users, [:client_id, :user_id], unique: true
  end
end
