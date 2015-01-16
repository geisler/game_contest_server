class AddMaxMatchToReferees < ActiveRecord::Migration
  def change
    add_column :referees, :max_match, :int
  end
end
