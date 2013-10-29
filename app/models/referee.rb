class Referee < ActiveRecord::Base
  belongs_to :programming_language
  has_many :contests
  has_many :matches, as: :manager

#  validates :programming_language, presence: true
  validates :file_location, presence: true

  def code=(uploaded_io)
    File.delete(self.file_location) unless self.file_location.nil? || !File.exists?(self.file_location)

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
end
