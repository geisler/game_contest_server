class UpdateContestsToFinalErd < ActiveRecord::Migration
  def change
    add_column :contests, :deadline, :datetime
    add_column :contests, :start, :datetime
    add_column :contests, :name, :string
    add_column :contests, :type, :string
    remove_column :contests, :documentation_path
  end
end
