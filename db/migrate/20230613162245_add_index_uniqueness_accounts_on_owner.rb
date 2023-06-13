class AddIndexUniquenessAccountsOnOwner < ActiveRecord::Migration[6.1]
  def change
    add_index :accounts, %i[owner handle], unique: true
  end
end
