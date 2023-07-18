class AddMinIdToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :min_id, :string
  end
end
