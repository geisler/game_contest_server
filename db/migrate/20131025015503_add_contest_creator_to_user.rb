class AddContestCreatorToUser < ActiveRecord::Migration
  def change
    add_column :users, :contest_creator, :boolean, default: false
  end
end
