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
   self.file_location = store_file(uploaded_io, self.class.to_s.downcase.pluralize, random_hex)
   uncompress(self.contest.referee.compressed_file_location, File.dirname(self.file_location)) if self.class == Player
end

def upload2=(uploaded_io)
    random_hex = SecureRandom.hex
    self.compressed_file_location = '' if self.compressed_file_location.nil?
    delete_code(self.compressed_file_location)
    self.compressed_file_location = store_file(uploaded_io, 'environments', random_hex)
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
      dir_location = Rails.root.join('code',
                                      dir,
				      Rails.env,
				      random_hex)
      file_location = dir_location.join(self.name).to_s
      dir_location = dir_location.to_s
      system("mkdir #{dir_location}")
      IO.copy_stream(uploaded_io, file_location)
      uncompress(file_location, dir_location)
   end
		
  file_location
  end

  def uncompress(src, dest)
puts "tar -xvf #{src} -C #{dest}"
    system("tar -xvf #{src} -C #{dest}") 
puts "unzip #{src} -d #{dest}"
    system("unzip #{src} -d #{dest}")
    system("chmod +x #{dest}/*")
    system("dos2unix -q #{dest}/*")
  end

 end

