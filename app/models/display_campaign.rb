class DisplayCampaign < ActiveRecord::Base
  attr_accessible :id, :name, :client_id, :promotion_id, :account_id, :create_user_id, :update_user_id
end
