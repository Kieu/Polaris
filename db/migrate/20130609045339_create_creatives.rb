class CreateCreatives < ActiveRecord::Migration
  def change
    create_table :creatives do |t|
      t.integer :ad_id, limt: 11
      t.string :creative_name, limit: 255
      t.string :image, limit: 512
      t.text :content
      t.column :display_type, "char(1)"
      t.column :del_flg, "char(1)"
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
