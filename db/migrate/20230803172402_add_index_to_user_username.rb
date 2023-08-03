class AddIndexToUserUsername < ActiveRecord::Migration[6.1]
  def change
    add_index :users, %i[username domain], unique: true
  end
end
