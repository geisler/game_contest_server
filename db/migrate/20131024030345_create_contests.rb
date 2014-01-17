class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.references :user, index: true
      t.references :contest_manager, index: true
      t.text :description
      t.string :documentation_path
      t.string :slug

      t.timestamps
    end
    add_index :contests, :slug, unique: true
  end
end
