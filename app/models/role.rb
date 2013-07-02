class Role < ActiveRecord::Base
  attr_accessible :role_name

  has_many :users

  validates :role_name, presence: true, length: {maximum: 50}
end
