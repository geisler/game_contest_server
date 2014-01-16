require 'uri'

class Referee < ActiveRecord::Base
#  belongs_to :programming_language
  belongs_to :user
  has_many :contests
  has_many :matches, as: :manager

  validates :user,              presence: true

  validates :name,              presence: true, uniqueness: true
  validates :rules_url,         format: { with: URI.regexp }
  validates :players_per_game,  numericality: { only_integer: true, greater_than: 0, less_than: 11 }

#  validates :programming_language, presence: true

  include Uploadable

  # Used for match.manager.referee when manager is a referee
  def referee
    self
  end
end
