class CreateMedias < ActiveRecord::Migration
  def change
    create_table :medias do |t|
      t.integer :id, limit: 11
      t.integer :media_category_id, limit: 11
      t.string :media_name, limit: 255
      t.column :del_flg, "char(1)", default: "0"
    end
  end
end
