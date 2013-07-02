class CreateConversions < ActiveRecord::Migration
  def change
    create_table :conversions do |t|
      t.integer :promotion_id, limit: 11
      t.string :conversion_name, limit: 255
      t.string :roman_name, limit: 255
      t.column :conversion_category, "char(1)"
      t.column :duplicate, "char(1)"
      t.column :unique_def, "char(2)"
      t.column :start_point, "char(1)"
      t.integer :sale_unit_price, limit: 11
      t.column :reward_form, "char(1)"
      t.column :os, "char(1)"
      t.column :conversion_mode, "char(1)"
      t.column :facebook_app_id, "bigint(20)"
      t.column :judging, "char(1)"
      t.column :track_type, "char(1)"
      t.column :track_method, "char(1)"
      t.text :url
      t.integer :session_period, limit: 11
      t.text :conversion_combine
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11
      t.string :mv, limit: 255

      t.timestamps
    end
    add_index :conversions, [:promotion_id, :conversion_name], unique: true
    add_index :conversions, [:promotion_id, :roman_name], unique: true
  end
end
