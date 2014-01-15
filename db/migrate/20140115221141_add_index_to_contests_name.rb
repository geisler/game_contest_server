class AddIndexToContestsName < ActiveRecord::Migration
  def change
    add_index :contests, :name, unique: true
  end
end
