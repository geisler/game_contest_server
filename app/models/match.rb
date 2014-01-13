class Match < ActiveRecord::Base
  belongs_to :manager, polymorphic: true
  belongs_to :match_type
  has_many :player_matches
  has_many :players, through: :player_matches

  validates :manager,           presence: true
  validates :status,            presence: true
  validates :earliest_start,    presence: true, unless: :started?
  validates :completion,
	    timeliness: { type: :datetime, on_or_before: :now },
	    if: :completed?
#  validates :match_type, presence: true

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

    if self.player_matches.count != self.manager.referee.players_per_game
      errors.add(:players, "doesn't match referee requirements")
    end
  end
end
