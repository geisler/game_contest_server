class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references :user, index: true
      t.references :contest, index: true
      t.string :code_path
      t.references :programming_language, index: true

      t.timestamps
    end
  end
end
