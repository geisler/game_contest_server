class ContestManager < ActiveRecord::Base
  belongs_to :programming_language
  has_many :contests
end
