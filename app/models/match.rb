class Match < ActiveRecord::Base
  belongs_to :manager, polymorphic: true
  belongs_to :match_type
  has_many :player_matches
  has_many :players, through: :player_matches

  validates :manager, presence: true
#  validates :match_type, presence: true
end
