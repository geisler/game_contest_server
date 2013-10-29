class RenameContestManagerToReferee < ActiveRecord::Migration
  def change
    rename_table :contest_managers, :referees
  end
end
