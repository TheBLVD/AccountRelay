class AddHandleToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :handle, :string
    add_index :accounts, %i[handle instance_id], unique: true
  end
end
