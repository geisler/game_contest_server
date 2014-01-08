class UpdateUsersToFinalErd < ActiveRecord::Migration
  def change
    add_column :users, :banned, :boolean, default: false
    add_column :users, :chat_url, :string
  end
end
