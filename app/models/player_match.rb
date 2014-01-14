class PlayerMatch < ActiveRecord::Base
  belongs_to :player
  belongs_to :match , inverse_of: :player_matches

  validates :player,    presence: true
  validates :match,     presence: true

  default_scope -> { order("player_matches.score DESC") }
  scope :wins, -> { where(result: 'Win') }
  scope :losses, -> { where(result: 'Loss') }
end
