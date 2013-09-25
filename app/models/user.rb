class User < ActiveRecord::Base
  has_secure_password

  validates :username, presence: true, length: { maximum: 25 }
  validates :email, presence: true
end
