class Agency < ActiveRecord::Base
  attr_accessible :agency_name, :roman_name
  include ApplicationHelper

  # VALID_ROMAN_NAME_REGEX = /^[A-Z_\ \~\!\@\#\$\%\^\&\*\(\)\_\-\+\=\<\,\>\.\;\:\"\'\{\}|\\\?\?\/a-z][A-Za-z_\ \~\!\@\#\$\%\^\&\*\(\)\_\-\+\=\<\,\>\.\;\:\"\'\{\}|\\\?\?\/\-0-9]*$/
  VALID_ROMAN_NAME_REGEX = /^[\s!-~]+$/
  has_many :promotions

  validates :agency_name, presence: true, uniqueness: {case_sensitive: false},
    length: {maximum: 255}
  validates :roman_name, presence: true, uniqueness: {case_sensitive: false},
    length: {maximum: 255}
  validates :roman_name, format: {with: VALID_ROMAN_NAME_REGEX}, if: -> agency { agency.roman_name.present?}
  scope :order_by_roman_name, ->{order :roman_name}
  
  def name_with_initial
    short_ja_name(self.agency_name)
  end
end
