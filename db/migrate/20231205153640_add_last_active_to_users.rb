class AddLastActiveToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_active, :integer
  end
end
