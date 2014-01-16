class PlayerTournament < ActiveRecord::Base
  belongs_to :player
  belongs_to :tournament

  validates :player, presence: true
  validates :tournament, presence: true
end
