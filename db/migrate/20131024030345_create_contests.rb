class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
      t.references :user, index: true
      t.references :contest_manager, index: true
      t.text :description
      t.string :documentation_path

      t.timestamps
    end
  end
end
