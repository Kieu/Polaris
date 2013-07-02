class PressRelease < ActiveRecord::Base
  attr_accessible :content, :create_user_id, :release_time, :update_user_id
end
