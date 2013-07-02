class DisplayAd < ActiveRecord::Base
  attr_accessible :id, :identifier, :name, :client_id, :promotion_id, :account_id, :display_campaign_id,
                  :display_group_id, :create_user_id, :update_user_id
end
