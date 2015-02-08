class AddRoundsCapableColumnToReferees < ActiveRecord::Migration
  def change
    add_column :referees, :rounds_capable, :boolean
  end
end
