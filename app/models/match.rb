class Match < ActiveRecord::Base
  belongs_to :contest
  belongs_to :match_type
end
