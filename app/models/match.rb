class Match < ActiveRecord::Base
  belongs_to :contest
  belongs_to :match_type
  has_many :player_matches
  has_many :players, through: :player_matches

  validates :contest, presence: true
  validates :match_type, presence: true
end