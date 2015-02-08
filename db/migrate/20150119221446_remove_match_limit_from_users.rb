class RemoveMatchLimitFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :match_limit, :int
  end
end
