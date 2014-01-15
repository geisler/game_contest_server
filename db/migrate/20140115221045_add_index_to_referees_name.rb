class AddIndexToRefereesName < ActiveRecord::Migration
  def change
    add_index :referees, :name, unique: true
  end
end
