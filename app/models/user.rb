class User < ActiveRecord::Base
  has_secure_password

  validates :username, presence: true, length: { maximum: 25 }
  #
  # Note that the email regex is from Michael Hartl's Rails tutorial
  # and does a "good enough" job.  It misses some addresses that are
  # officially acceptable, but silly to check for.  He even has a more
  # robust email regex in his homework section at the end of Chapter 6.
  #
  validates :email, presence: true,
		    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
end
