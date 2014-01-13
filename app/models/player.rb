class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest
  belongs_to :programming_language
  has_many :player_matches
  has_many :matches, through: :player_matches

  validates :user,          presence: true
  validates :contest,       presence: true
  validates :description,   presence: true
  validates :name,          presence: true, uniqueness: { scope: :contest }
#  validates :programming_language, presence: true

  include Uploadable
end
