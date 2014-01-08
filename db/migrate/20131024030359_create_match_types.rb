class CreateMatchTypes < ActiveRecord::Migration
  def change
    create_table :match_types do |t|
      t.string :kind

      t.timestamps
    end
  end
end
