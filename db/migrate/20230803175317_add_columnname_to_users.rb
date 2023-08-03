class AddColumnnameToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :following_count, :int, default: 0
    add_column :users, :followers_count, :int, default: 0
  end
end
