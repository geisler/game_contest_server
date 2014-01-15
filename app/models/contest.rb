class Contest < ActiveRecord::Base
  belongs_to :user
  belongs_to :referee
  has_many :players
  has_many :tournaments

  validates :referee,       presence: true
  validates :user,          presence: true

  validates :deadline,      timeliness: { type: :datetime, allow_nil: false, on_or_after: :now }
  validates :description,   presence: true
  validates :name,          presence: true, uniqueness: true
end
