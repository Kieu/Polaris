class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :role_name, limit: 50
      t.column :status, "char(1)", default: "0"
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11

      t.timestamps
    end
  end
end
