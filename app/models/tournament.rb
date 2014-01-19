class Tournament < ActiveRecord::Base
  belongs_to :contest
  has_many :player_tournaments, inverse_of: :tournament , dependent: :destroy
  has_many :players, through: :player_tournaments
  has_many :matches, as: :manager , dependent: :destroy


  validates :contest,             presence: true
  validates :name,                presence: true, uniqueness: { scope: :contest }
  validates :start,               presence: true, timeliness: { type: :datetime, allow_nil: false }
  validates :tournament_type,     presence: true, inclusion: ['round robin', 'single elimination']
  # Validate that the status is one of the required statuses
  validates :status,              presence: true, inclusion: %w[waiting started completed]

  def referee
    contest.referee
  end

  def self.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      all
    end
  end

  def player_ids=(ids)
    ids.each do |p, use|
      self.player_tournaments.build(player: Player.find(p))
    end
  end


  extend FriendlyId
  friendly_id :name, use: :slugged
  after_validation :move_friendly_id_error_to_name

  def move_friendly_id_error_to_name
    errors.add :name, *errors.delete(:friendly_id) if errors[:friendly_id].present?
  end


end
