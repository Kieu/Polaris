class RedirectInformation < ActiveRecord::Base
  attr_accessible :mpv, :client_id, :promotion_id, :media_category_id, :media_id,
    :account_id, :campaign_id, :group_id, :unit_id, :creative_id, :click_unit,
    :comment, :del_flg
end
