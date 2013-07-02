class CreateRedirectInfomations < ActiveRecord::Migration
  def change
    create_table :redirect_infomations do |t|
      t.string :mpv, limit: 255
      t.integer :client_id, limit: 11
      t.integer :promotion_id, limit: 11
      t.integer :media_category_id, limit: 11
      t.integer :media_id, limit: 11
      t.integer :account_id, limit: 11
      t.column :campaign_id, "bigint(20)"
      t.column :group_id, "bigint(20)"
      t.column :unit_id, "bigint(20)"
      t.column :creative_id, "bigint(20)"
      t.integer :click_unit, limit: 11
      t.text :comment
      t.column :del_flg, "char(1)"
      t.datetime :created_at
      t.integer :create_usr_id, limit: 11
      t.datetime :updated_at
      t.integer :update_usr_id, limit: 11
    end
  end
end
