class UpdateMatchesToFinalErd < ActiveRecord::Migration
  def change
    remove_column :matches, :duration
    add_column :matches, :status, :string
    rename_column :matches, :occurance, :completion
    add_column :matches, :earliest_start, :datetime

    rename_column :matches, :contest_id, :manager_id
    add_column :matches, :manager_type, :string
    add_index :matches, [:manager_id, :manager_type]
  end
end
