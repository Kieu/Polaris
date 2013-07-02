class ChangeColumsFromConversionsTable < ActiveRecord::Migration
  def change
    remove_column :conversions, :conversion_category
    remove_column :conversions, :duplicate
    remove_column :conversions, :unique_def
    remove_column :conversions, :start_point
    remove_column :conversions, :reward_form
    remove_column :conversions, :os
    remove_column :conversions, :conversion_mode
    remove_column :conversions, :judging
    remove_column :conversions, :track_type
    remove_column :conversions, :track_method
    remove_column :conversions, :facebook_app_id
    
    add_column :conversions, :conversion_category, "char(1)"
    add_column :conversions, :duplicate, "char(1)"
    add_column :conversions, :unique_def, "char(2)"
    add_column :conversions, :start_point, "char(1)"
    add_column :conversions, :reward_form, "char(1)"
    add_column :conversions, :os, "char(1)"
    add_column :conversions, :conversion_mode, "char(1)"
    add_column :conversions, :judging, "char(1)"
    add_column :conversions, :track_type, "char(1)"
    add_column :conversions, :track_method, "char(1)"
    add_column :conversions, :facebook_app_id, "bigint(20)"
  end
end
