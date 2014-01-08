class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :contest, index: true
      t.datetime :occurance
      t.references :match_type, index: true
      t.float :duration

      t.timestamps
    end
  end
end
