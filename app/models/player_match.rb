class PlayerMatch < ActiveRecord::Base
  belongs_to :player
  belongs_to :match

  validates :player, presence: true
  validates :match, presence: true
end
