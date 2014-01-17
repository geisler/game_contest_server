class Match < ActiveRecord::Base
  belongs_to :manager, polymorphic: true
  belongs_to :match_type
  has_many :player_matches , inverse_of: :match
  has_many :players, through: :player_matches

  has_many :parent_matches, :class_name => 'MatchPath', :foreign_key => 'parent_match_id'
  has_many :child_matches, :class_name => 'MatchPath', :foreign_key => 'child_match_id'

  validates :manager,           presence: true
  validates :status,            presence: true
  validates :earliest_start,    presence: true, unless: :started?
  validates :completion,
	    timeliness: { type: :datetime, on_or_before: :now },
	    if: :completed?
#  validates :match_type, presence: true
    accepts_nested_attributes_for :player_matches


  validate :correct_number_of_players

  def completed?
    status == 'Completed'
  end

  def started?
    %w(Started Completed).include? status
  end

  def waiting?
    status == 'Waiting'
  end

  def correct_number_of_players
    return if self.player_matches.nil? || self.manager.nil?

=begin
    if self.player_matches.count != self.manager.referee.players_per_game
      errors.add(:players, "doesn't match referee requirements for number of players")
    end
=end

      errors.add(:players, "number of players must equal " + self.manager.referee.players_per_game.to_s + " you have " + self.player_matches.length.to_s + " players") unless self.player_matches.length == self.manager.referee.players_per_game

  end
end
