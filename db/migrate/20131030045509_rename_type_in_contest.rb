class RenameTypeInContest < ActiveRecord::Migration
  def change
    rename_column :contests, :type, :contest_type
  end
end
