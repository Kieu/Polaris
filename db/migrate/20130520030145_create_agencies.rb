class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :agency_name, limit: 255
      t.string :roman_name, limit: 255
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11

      t.timestamps
    end
    add_index :agencies, :agency_name, unique: true
    add_index :agencies, :roman_name, unique: true
  end
end
