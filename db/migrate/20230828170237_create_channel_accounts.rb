class CreateChannelAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :channel_accounts, id: :uuid do |t|
      t.references :user_id, null: false, type: :uuid
      t.references :channel_id, null: false, type: :uuid

      t.timestamps
    end
  end
end
