class Contest < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest_manager
  has_many :matches
  has_many :players
end
