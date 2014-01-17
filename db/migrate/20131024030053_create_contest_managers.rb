class CreateContestManagers < ActiveRecord::Migration
  def change
    create_table :contest_managers do |t|
      t.string :code_path
      t.references :programming_language, index: true
      t.string :slug

      t.timestamps
    end
    add_index :contest_managers, :slug, unique: true
  end
end
