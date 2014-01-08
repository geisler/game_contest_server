class UpdateRefereesToFinalErd < ActiveRecord::Migration
  def change
    rename_column :referees, :code_path, :file_location
    add_column :referees, :name, :string
    add_column :referees, :rules_url, :string
    add_column :referees, :players_per_game, :integer
    add_column :referees, :user_id, :integer

    add_index :referees, :user_id, name: "index_referees_on_user_id"
  end
end
