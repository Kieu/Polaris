class CreatePressReleases < ActiveRecord::Migration
  def change
    create_table :press_releases do |t|
      t.text :content
      t.datetime :release_time
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11

      t.timestamps
    end
  end
end
