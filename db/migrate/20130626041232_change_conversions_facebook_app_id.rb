class ChangeConversionsFacebookAppId < ActiveRecord::Migration
  def change
    remove_column :conversions, :facebook_app_id
    add_column :conversions, :facebook_app_id, "varchar(20)"
  end
end
