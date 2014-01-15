class Tournament < ActiveRecord::Base
    belongs_to :contest
    has_many :matches, as: :manager
    has_many :player_tournaments
    has_many :players, through: :player_tournaments

    validates :contest,             presence: true
    validates :name,                presence: true, uniqueness: { scope: :contest }
    validates :start,               presence: true, timeliness: { type: :datetime, allow_nil: false }
    validates :tournament_type,     presence: true, inclusion: ['round robin', 'single elimination']
    # Validate that the status is one of the required statuses
    validates :status,              presence: true, inclusion: %w[waiting pending completed]

    def referee
      contest.referee
    end
end
