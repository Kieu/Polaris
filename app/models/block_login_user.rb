class BlockLoginUser < ActiveRecord::Base
  attr_accessible :block_at_time, :login_fail_num, :user_id
  
  belongs_to :user
end