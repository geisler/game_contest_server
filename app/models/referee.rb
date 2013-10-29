class Referee < ActiveRecord::Base
  belongs_to :programming_language
  has_many :contests

  validates :programming_language, presence: true
  validates :code_path, presence: true

  def code=(uploaded_io)
    File.delete(self.code_path) unless self.code_path.nil? || !File.exists?(self.code_path)

    if uploaded_io.nil?
      self.code_path = ''
    else
      self.code_path = Rails.root.join('code',
				       'referees',
				       Rails.env,
				       Time.now.strftime("%Y%m%d%H%M%S%L-#{Process.pid.to_s}") ).to_s
      IO.copy_stream(uploaded_io, self.code_path)
    end
  end
end
