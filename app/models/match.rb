class Match < ActiveRecord::Base
  belongs_to :manager, polymorphic: true
  has_many :player_matches , inverse_of: :match
  has_many :players, through: :player_matches

  accepts_nested_attributes_for :player_matches

  validates :manager,           presence: true
  validates :status,          presence: true, inclusion: %w[waiting started completed]
  validates :earliest_start,    presence: true, unless: :started?
  validates :completion,
	    timeliness: { type: :datetime, on_or_before: :now },
	    if: :completed?


  validate :correct_number_of_players
  validate :players_allowed_to_play, if: :tournament_match?

  def completed?
    status == 'completed'
  end

  def started?
    %w(started completed).include? status
  end

  def waiting?
    status == 'waiting'
  end

  def correct_number_of_players
    return if self.player_matches.nil? || self.manager.nil?

    unless self.player_matches.length == self.manager.referee.players_per_game
      errors.add(:players, "number of players must equal " + self.manager.referee.players_per_game.to_s + ": You have " + self.player_matches.length.to_s + " players.")
    end

  end

  def tournament_match?
    return if self.manager.nil?

    self.manager_type == "Tournament"
  end

  # Makes sure players are in the tournament the match is in
  def players_allowed_to_play
    return if self.manager.nil? || self.players.nil?

    self.players.each do |p|
      unless p.tournaments.include? self.manager
        errors.add(:match, "players must be in same tournament as match")
      end
    end
  end
end
