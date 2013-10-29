class UseRefereeIdInTables < ActiveRecord::Migration
  def change
    rename_column :contests, :contest_manager_id, :referee_id
  end
end
