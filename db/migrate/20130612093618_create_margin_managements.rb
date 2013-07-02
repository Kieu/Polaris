class CreateMarginManagements < ActiveRecord::Migration
  def change
    create_table :margin_managements do |t|
      t.integer :report_ymd, limit: 11
      t.integer :account_id, limit: 11
      t.float :margin_rate
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11

      t.timestamps
    end
  end
end
