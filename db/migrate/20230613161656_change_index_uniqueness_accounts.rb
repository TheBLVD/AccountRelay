class ChangeIndexUniquenessAccounts < ActiveRecord::Migration[6.1]
  def change
    remove_index :accounts, name: 'index_accounts_on_handle_and_instance_id'
  end
end
