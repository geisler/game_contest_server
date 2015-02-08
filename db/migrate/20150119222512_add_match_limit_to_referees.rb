class AddMatchLimitToReferees < ActiveRecord::Migration
  def change
    add_column :referees, :match_limit, :int
  end
end
