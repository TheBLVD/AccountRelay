class AddOwnerToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :owner, :string
    add_index :accounts, :owner
  end
end
