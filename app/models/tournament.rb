class Tournament < ActiveRecord::Base
    belongs_to :contest
    has_many :matches

    validates :contest, presence: true
    validates :start, timeliness: { type: :datetime, allow_nil: false }
    validates :tournament_type,  presence: true


end
