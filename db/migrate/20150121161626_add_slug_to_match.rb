class AddSlugToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :slug, :string
    add_index :matches, :slug, unique: true
  end
end
