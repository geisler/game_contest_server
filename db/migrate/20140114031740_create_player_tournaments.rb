class CreatePlayerTournaments < ActiveRecord::Migration
  def change
    create_table :player_tournaments do |t|
      t.references :tournament
      t.references :player


      t.timestamps
    end
  end
end
