class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :promotion_name, limit: 255
      t.string :roman_name, limit: 255
      t.integer :promotion_category_id, limit: 11
      t.integer :client_id, limit: 11
      t.integer :tracking_period, limit: 4
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11
      t.column :del_flg, "char(1)", default: "0"

      t.timestamps
    end
    add_index :promotions, [:promotion_name, :client_id], unique: true
    add_index :promotions, [:roman_name, :client_id], unique: true
  end
end
