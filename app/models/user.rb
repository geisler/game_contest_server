class User < ActiveRecord::Base
  has_secure_password

  has_many :referees
  has_many :players
  has_many :contests

  validates :username, presence: true, length: { maximum: 25 }, uniqueness: true

  #
  # Note that the email regex is from Michael Hartl's Rails tutorial
  # and does a "good enough" job.  It misses some addresses that are
  # officially acceptable, but silly to check for.  He even has a more
  # robust email regex in his homework section at the end of Chapter 6.
  #
  validates :email, presence: true,
    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }

  def self.search(search)
    if search
      where('username LIKE ?', "%#{search}%")
    else
      all
    end
  end

  extend FriendlyId
  friendly_id :username, use: :slugged
  after_validation :move_friendly_id_error_to_username

  def move_friendly_id_error_to_username
    errors.add :username, *errors.delete(:friendly_id) if errors[:friendly_id].present?
  end
end
