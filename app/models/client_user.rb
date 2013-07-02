class ClientUser < ActiveRecord::Base
  self.table_name = "clients_users"
  attr_accessible :client_id, :user_id, :del_flg
 
  validates :client_id, presence: true
  validates :user_id, presence: true

  belongs_to :client
  belongs_to :user

  scope :active, where(del_flg: Settings.client_user.active)
 
  def active?
    self.del_flg == Settings.client_user.active
  end
end
