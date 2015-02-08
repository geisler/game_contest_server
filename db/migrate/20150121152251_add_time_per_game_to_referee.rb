class AddTimePerGameToReferee < ActiveRecord::Migration
  def change
    add_column :referees, :time_per_game, :integer
  end
end
