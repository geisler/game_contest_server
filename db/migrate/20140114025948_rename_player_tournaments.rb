class RenamePlayerTournaments < ActiveRecord::Migration
  def change
      rename_table :Player_Tournaments, :Player_Tournament
  end
end
