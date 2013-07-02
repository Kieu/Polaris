class Promotion < ActiveRecord::Base
  attr_accessible :promotion_category_id, :promotion_name, :roman_name, :tracking_period,
    :client_id, :del_flg, :update_user_id

  # VALID_ROMAN_NAME_REGEX = /^[A-Z_\ \~\!\@\#\$\%\^\&\*\(\)\_\-\+\=\<\,\>\.\;\:\"\'\{\}|\\\?\?\/a-z][A-Za-z_\ \~\!\@\#\$\%\^\&\*\(\)\_\-\+\=\<\,\>\.\;\:\"\'\{\}|\\\?\?\/\-0-9]*$/
  VALID_ROMAN_NAME_REGEX = /^[\s!-~]+$/
  VALID_NUMBER_REGEX = /^\d+$/

  belongs_to :client
  belongs_to :agency
  has_many :conversions
  has_many :accounts

  validates :promotion_name, presence: true, uniqueness: {scope: :client_id}
  validates :roman_name, presence: true, uniqueness: {scope: :client_id}
  validates :roman_name, format: {with: VALID_ROMAN_NAME_REGEX}, if: -> promotion { promotion.roman_name.present?}
  validates :promotion_category_id, presence: true
  validates :tracking_period, presence: true
  validates :tracking_period,
    numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 90},
    if: -> promotion {promotion.tracking_period.present?}
  validates :client_id, presence: true

  scope :order_by_promotion_name, ->{order :promotion_name}
  scope :order_id_desc, ->{order("id DESC")}
  scope :order_by_roman_name, ->{order :roman_name}
  scope :get_by_client, lambda {|client_id| where(client_id: client_id)}
  scope :active, ->{where(del_flg: 0)}

  def delete
    self.update_attribute(:del_flg, Settings.promotion.deleted)
  end

  def deleted?
    self.del_flg == Settings.promotion.deleted
  end
end
