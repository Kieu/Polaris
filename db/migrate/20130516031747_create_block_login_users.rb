class CreateBlockLoginUsers < ActiveRecord::Migration
  def change
    create_table :block_login_users do |t|
      t.integer :user_id, limit: 11
      t.datetime :block_at_time
      t.integer :login_fail_num, limit: 4
    end
  end
end