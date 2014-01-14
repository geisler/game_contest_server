class UpdateContestsToFinalErd < ActiveRecord::Migration
  def change
    add_column :contests, :deadline, :datetime
    add_column :contests, :name, :string
    remove_column :contests, :documentation_path
  end
end
