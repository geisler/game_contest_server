class ContestManager < ActiveRecord::Base
  belongs_to :programming_language
  has_many :contests

  validates :programming_language, presence: true
end
