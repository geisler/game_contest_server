class Tournament < ActiveRecord::Base
    belongs_to :contest
    has_many :player_tournaments, inverse_of: :tournament
    has_many :players, through: :player_tournaments 
    has_many :matches

    validates :contest,             presence: true
    validates :name,                presence: true, uniqueness: { scope: :contest }
    validates :start,               presence: true, timeliness: { type: :datetime, allow_nil: false }
    validates :tournament_type,     presence: true, inclusion: ['round robin', 'single elimination']

end
