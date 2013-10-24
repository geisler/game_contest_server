class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest
  belongs_to :programming_language
  has_many :player_matches
  has_many :matches, through: :player_matches
end
