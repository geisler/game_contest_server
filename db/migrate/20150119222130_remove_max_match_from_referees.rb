class RemoveMaxMatchFromReferees < ActiveRecord::Migration
  def change
    remove_column :referees, :max_match, :int
  end
end
