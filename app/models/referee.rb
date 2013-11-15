require 'uri'

class Referee < ActiveRecord::Base
#  belongs_to :programming_language
  belongs_to :user
  has_many :contests
  has_many :matches, as: :manager

#  validates :programming_language, presence: true
  validates :name, presence: true, uniqueness: true
  validates :rules_url, format: { with: URI.regexp }
  validates :file_location, presence: true
  validates :players_per_game, numericality: { only_integer: true, greater_than: 0, less_than: 11 }

  before_destroy :delete_code

  def upload=(uploaded_io)
    self.file_location = '' if self.file_location.nil?
    delete_code

    if uploaded_io.nil?
      self.file_location = ''
    else
      self.file_location = Rails.root.join('code',
					   'referees',
					   Rails.env,
					   Time.now.strftime("%Y%m%d%H%M%S%L-#{Process.pid.to_s}") ).to_s
      IO.copy_stream(uploaded_io, self.file_location)
    end
  end

  private

    def delete_code
      File.delete(self.file_location) if File.exists?(self.file_location)
    end
end
