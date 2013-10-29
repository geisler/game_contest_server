class FixPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :code_path
    add_column :players, :file_location, :string
  end
end
