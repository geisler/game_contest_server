require 'uri'

class Referee < ActiveRecord::Base
#  belongs_to :programming_language
  belongs_to :user
  has_many :contests
  has_many :matches, as: :manager

#  validates :programming_language, presence: true
  validates :name, presence: true, uniqueness: true
  validates :rules_url, format: { with: URI.regexp }
  validates :players_per_game, numericality: { only_integer: true, greater_than: 0, less_than: 11 }

  include Uploadable

  def referee
    self
  end
end
