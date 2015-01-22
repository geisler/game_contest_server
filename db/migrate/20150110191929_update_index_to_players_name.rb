class UpdateIndexToPlayersName < ActiveRecord::Migration
  def change
     remove_index :players, :name
     add_index :players, [:name, :contest_id], unique: true
  end
end
