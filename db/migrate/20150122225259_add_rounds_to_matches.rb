class AddRoundsToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :rounds, :integer
  end
end
