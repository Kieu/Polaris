class User < ActiveRecord::Base
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]{2,}+\z/i
  VALID_ROMAN_NAME_REGEX = /^[\s!-~]+$/

  attr_accessible :username, :roman_name, :email, :company_id, :role_id,
    :password_flg

  belongs_to :role
  has_many :client_users
  has_one :block_login_user

  validates :username, presence: true, uniqueness: {case_sensitive: false},
    length: {maximum: 255}
  validates :roman_name, presence: true, uniqueness: {case_sensitive: false},
    length: {maximum: 255}
  validates :roman_name, format: {with: VALID_ROMAN_NAME_REGEX},
    if: -> user {user.roman_name.present?}
  validates :email, presence: true, uniqueness: {case_sensitive: false}
  validates :email, format: {with: VALID_EMAIL_REGEX}, length: {maximum: 255},
    if: -> user {user.email.present?}
  validates :company_id, presence: true
  validates :role_id, presence: true
  validates :password_flg, presence: true
 
  scope :order_by_roman_name, ->{order :roman_name}
  scope :active, where(status: Settings.user.active)

  before_save {|user| user.email = email.downcase}
 
  def can_login?
    return false if self.status == Settings.user.deactive
    if self.block_login_user && self.block_login_user.login_fail_num >=
      Settings.login.login_block_number
      if self.block_login_user.block_at_time > 5.minutes.ago
        return false
      else
        return self.remove_block_login
      end
    else
      return true
    end
  end
 
  def update_login_fail
    block = self.block_login_user
    if block
      if block.login_fail_num < Settings.login.login_block_number
        block.login_fail_num += 1
        block.block_at_time = Time.now if block.login_fail_num >=
          Settings.login.login_block_number
        block.save!
      end
    else
      BlockLoginUser.create(user_id: self.id, login_fail_num: 1)
    end
  end

  def toggle_enabled
    self.status = self.active? ? Settings.user.deactive : Settings.user.active
    self.del_client_user if self.deactive?
    self.save!
  end
 
  def remove_block_login
    self.block_login_user.login_fail_num = 0
    self.block_login_user.block_at_time = nil
    self.block_login_user.save
  end
 
  def valid_attribute?(attribute_name)
    self.valid?
    self.errors[attribute_name].blank?
  end

  def active?
    self.status == Settings.user.active
  end

  def deactive?
    self.status == Settings.user.deactive
  end
 
  def super?
    self.role_id == Settings.role.SUPER
  end
 
  def client?
    self.role_id == Settings.role.CLIENT
  end
 
  def agency?
    self.role_id == Settings.role.AGENCY
  end
 
  def del_client_user
    self.client_users.each do |client_user|
      client_user.update_attributes!(del_flg: Settings.client_user.deleted)
    end
  end
end
