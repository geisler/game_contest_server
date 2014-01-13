class Contest < ActiveRecord::Base
  belongs_to :user
  belongs_to :referee
  has_many :matches, as: :manager
  has_many :players

  validates :referee,       presence: true
  validates :user,          presence: true

  validates :deadline,      timeliness: { type: :datetime, allow_nil: false, on_or_after: :now }
  validates :start,         timeliness: { type: :datetime, allow_nil: false, 
                                                on_or_after: lambda { |rec| rec.deadline } }
  validates :description,   presence: true
  validates :name,          presence: true, uniqueness: true
  validates :contest_type,  presence: true
end
