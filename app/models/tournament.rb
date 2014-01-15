class Tournament < ActiveRecord::Base
    belongs_to :contest
    has_many :matches

    validates :contest,             presence: true
    validates :name,                presence: true, uniqueness: { scope: :contest }
    validates :start,               presence: true, timeliness: { type: :datetime, allow_nil: false }
    validates :tournament_type,     presence: true, inclusion: ['round robin', 'single elimination']
    validates :status,              presence: true
    # Validate that the status is one of the required statuses?
    #validates :status,              presence: true, inclusion: %w[waiting pending completed]

end
