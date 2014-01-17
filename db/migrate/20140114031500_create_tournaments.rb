class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string :tournament_type
      t.references :contest
      t.datetime :start
      t.string :name
      t.string :status
      t.string :slug

      t.timestamps
    end
    add_index :tournaments, :slug, unique: true
  end
end
