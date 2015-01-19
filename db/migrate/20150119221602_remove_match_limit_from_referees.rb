class RemoveMatchLimitFromReferees < ActiveRecord::Migration
  def change
    remove_column :referees, :match_limit, :int
  end
end
