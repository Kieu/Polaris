class BackgroundJob < ActiveRecord::Base
  attr_accessible :user_id, :filename, :type_view, :status, :filepath, :job_id
end
