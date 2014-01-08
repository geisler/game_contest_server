class UpdatePlayersToFinalErd < ActiveRecord::Migration
  def change
    change_column :players, :code_path, :file_location
    add_column :players, :description, :text
    add_column :players, :name, :string
    add_column :players, :downloadable, :boolean, default: false
    add_column :players, :playable, :boolean, default: true
  end
end
