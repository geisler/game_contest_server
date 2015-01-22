class AddCompressedFileLocationToReferee < ActiveRecord::Migration
  def change
    add_column :referees, :compressed_file_location, :string
  end
end
