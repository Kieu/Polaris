class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :promotion_id, limit: 11
      t.integer :media_id, limit: 11
      t.integer :media_category_id, limit: 11
      t.string :sync_account_id, limit: 255
      t.string :sync_account_pw, limit: 255
      t.string :account_name, limit: 255
      t.string :roman_name, limit: 255
      t.column :sync_flg, "char(1)"
      t.float :margin
      t.column :del_flg, "char(1)", default: "0"
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11

      t.timestamps
    end
  end
end
