class AddMatchLimitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :match_limit, :int
  end
end
