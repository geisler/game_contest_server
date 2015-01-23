class AddRoundsPerMatchToTournaments < ActiveRecord::Migration
  def change
    add_column :tournaments, :rounds_per_match, :integer
  end
end
