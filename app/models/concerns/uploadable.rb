module Uploadable
  extend ActiveSupport::Concern

  included do
    before_destroy :delete_code
    validate :file_location_exists
  end

def upload=(uploaded_io)
   random_hex = SecureRandom.hex
   self.file_location = '' if self.file_location.nil?
   delete_code(self.file_location)
   system("mkdir -p /home/pkramer/Project/code/#{self.class.to_s.downcase.pluralize}/development/#{random_hex}")
   self.file_location = store_file(uploaded_io, self.class.to_s.downcase.pluralize, random_hex)
end

def upload2=(uploaded_io)
    random_hex = SecureRandom.hex
    self.compressed_file_location = '' if self.compressed_file_location.nil?
    delete_code(self.compressed_file_location)
    system("mkdir -p /home/pkramer/Project/code/environments/development/#{random_hex}")
    self.compressed_file_location = store_file(uploaded_io, 'environments', random_hex)
    system("tar -xvf #{compressed_file_location} -C /home/pkramer/Project/code/environments/development/#{random_hex}") 
#    system("tar -xvf #{uploaded_io}")
    system("unzip #{self.compressed_file_location} -d /home/pkramer/Project/code/environments/development/#{random_hex}")
end

#def compressed_file_location_exists
#   if self.compressed_file_location.nil? || !File.exists?(self.compressed_file_location)
#	errors.add(:compressed_file_location, "doesn't exist on the server")
#   end
#end 
 def file_location_exists
   if self.file_location.nil? || !File.exists?(self.file_location)
      errors.add(:file_location, "doesn't exist on the server")
   end
 end

  private

  def delete_code(location)
    File.delete(location) if File.exists?(location)
  end

  def store_file(uploaded_io, dir, random_hex)
    file_location = ''
    unless uploaded_io.nil?
      file_location = Rails.root.join('code',
                                      dir,
				      Rails.env,
				      random_hex,
				      self.name).to_s
      IO.copy_stream(uploaded_io, file_location)
      system("chmod +x #{file_location}")
      system("dos2unix -q #{file_location}")
   end

   file_location
  end

 end
