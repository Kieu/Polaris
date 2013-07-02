class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :client_name, limit: 255
      t.string :roman_name, limit: 255
      t.string :tel, limit: 255
      t.column :contract_flg, "char(1)", default: "1"
      t.column :contract_type, "char(1)", default: "0"
      t.column :del_flg, "char(1)", default: "0"
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11
      t.string :person_charge, limit: 255
      t.string :person_sale, limit: 255

      t.timestamps
    end
    add_index :clients, :client_name, unique: true
    add_index :clients, :roman_name, unique: true
  end
end
