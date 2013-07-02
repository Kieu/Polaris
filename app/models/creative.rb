class Creative < ActiveRecord::Base
  attr_accessible :ad_id, :creative_name, :image, :create_user_id, :update_user_id
end
