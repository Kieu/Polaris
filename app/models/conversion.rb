class Conversion < ActiveRecord::Base
  VALID_NUMBER_REGEX = /^\d+$/
  VALID_ROMAN_NAME_REGEX = /^[\s!-~]+$/
  
  attr_accessible :conversion_category, :conversion_combine, :conversion_mode,
    :conversion_name, :duplicate, :facebook_app_id, :judging, :os, :reward_form,
    :roman_name, :sale_unit_price, :session_period, :start_point, :track_method,
    :track_type, :unique_def, :url

  belongs_to :promotion

  validates :conversion_name, length: {maximum: 255},
    presence: true, uniqueness: {scope: :promotion_id}
  validates :roman_name, length: {maximum: 255},
    presence: true, uniqueness: {scope: :promotion_id}
  validates :roman_name, format: {with: VALID_ROMAN_NAME_REGEX}, if: -> conversion {conversion.roman_name.present?}
  validates :conversion_category, presence: true
  validates :track_type, presence: true, if: :check_app
  validates_inclusion_of :session_period, in: 1..90, if: :check_track_type_2
  validates :unique_def, presence: true, if: :check_conversion_category
  validates :os, presence: true, if: :check_track_type_1
  validates :conversion_mode, presence: true, if: :check_track_type_1
  validates :duplicate, presence: true, if: :check_track_type_1
  validates :track_method, presence: true, if: :check_conversion_mode_1
  validates :facebook_app_id, presence: true , if: :check_fb_id_valid
  validates :facebook_app_id, length: {maximum: 20}, format: {with: VALID_NUMBER_REGEX},
    numericality: {only_integer: true, less_than_or_equal_to: 18446744073709551615},
    if: -> conversion {conversion.facebook_app_id.present?}
  validates :start_point, presence: true, if: :check_web
  validates :conversion_combine, presence: true, if: :check_combination
  validates :url, presence: true, if: :check_track_method
  validates :sale_unit_price, length: {maximum: 10}, format: {with: VALID_NUMBER_REGEX},
    numericality: {only_integer: true, less_than_or_equal_to: 2147483647}, if: :check_sales?

  scope :order_by_roman_name, ->{order :roman_name}
  scope :order_by_id, ->{order :id}
  scope :get_by_promotion_id, lambda {|promotion_id| where(promotion_id: promotion_id)}

  def create_mv
    mv = ""
    if (client_id = self.promotion.client_id.to_s(36)).length < 8
      mv << "0" * (8 - client_id.length) << client_id
    end
    if (promotion_id = self.promotion.id.to_s(36)).length < 8
      mv << "0" * (8 - promotion_id.length) << promotion_id
    end
    if (conversion_id = self.id.to_s(36)).length < 8
      mv << "0" * (8 - conversion_id.length) << conversion_id
    end
    mv << SecureRandom.urlsafe_base64(6)
    mv = Digest::MD5::hexdigest(mv)
    self.update_attribute(:mv, mv)
  end

  private
  def check_conversion_category
    conversion_category.to_i == 1 || conversion_category.to_i == 2
  end

  def check_web
    conversion_category.to_i == 1
  end

  def check_app
    conversion_category.to_i == 2
  end

  def check_combination
    conversion_category.to_i == 3
  end

  def check_track_type_1
    track_type.to_i == 1
  end

  def check_track_type_2
    conversion_category.to_i == 2 && track_type.to_i == 2
  end

  def check_track_method
    track_method.to_i == 4
  end

  def check_conversion_mode_1
    track_type.to_i == 1 && conversion_mode.to_i != 1
  end
  
  def check_fb_id_valid
    conversion_category.to_i == 2 && track_type.to_i == 1 && conversion_mode.to_i != 2
  end
  
  def check_sales?
    !sale_unit_price.blank? 
  end
end
