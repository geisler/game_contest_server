class Contest < ActiveRecord::Base
  belongs_to :user
  belongs_to :referee
  has_many :tournaments
  has_many :players

  validates :referee,       presence: true
  validates :user,          presence: true

  validates :deadline,      timeliness: { type: :datetime, allow_nil: false, on_or_after: :now }
  validates :description,   presence: true
  validates :name,          presence: true, uniqueness: true

   def self.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      all
    end
  end
end
