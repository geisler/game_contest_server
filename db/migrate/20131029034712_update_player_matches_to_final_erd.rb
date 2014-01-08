class UpdatePlayerMatchesToFinalErd < ActiveRecord::Migration
  def change
    add_column :player_matches, :result, :string
  end
end
