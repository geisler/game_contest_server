module Uploadable
  extend ActiveSupport::Concern

  included do
    before_destroy :delete_code
  end

  def upload=(uploaded_io)
    self.file_location = '' if self.file_location.nil?
    delete_code

    if uploaded_io.nil?
      self.file_location = ''
    else
      self.file_location = Rails.root.join('code',
					   self.class.to_s.downcase.pluralize,
					   Rails.env,
					   SecureRandom.hex).to_s
      IO.copy_stream(uploaded_io, self.file_location)
    end
  end

  private

    def delete_code
      File.delete(self.file_location) if File.exists?(self.file_location)
    end
end
