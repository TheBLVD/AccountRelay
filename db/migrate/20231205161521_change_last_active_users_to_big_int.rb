class ChangeLastActiveUsersToBigInt < ActiveRecord::Migration[6.1]
  def up
    change_column :users, :last_active, :bigint
  end
end
