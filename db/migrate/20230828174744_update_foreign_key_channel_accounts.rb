class UpdateForeignKeyChannelAccounts < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :channel_accounts, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :channel_accounts, :channels, column: :channel_id, on_delete: :cascade
  end
end
