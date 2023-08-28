class DropFixChannelAccounts < ActiveRecord::Migration[6.1]
  def change
    drop_table :channel_accounts
    create_table :channel_accounts, id: :uuid do |t|
      t.references :user, null: false, type: :uuid
      t.references :channel, null: false, type: :uuid

      t.timestamps
    end
  end
end
