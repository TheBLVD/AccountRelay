class DropAndAddAccountToUserColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :follows, :target_account_id
    remove_column :follows, :account_id

    add_column :follows, :user_id, :integer, null: false
    add_column :follows, :target_user_id, :integer, null: false
    add_index :follows, %i[user_id target_user_id], unique: true
  end
end
