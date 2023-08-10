class UsersForYouSettings < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :for_you_settings, :jsonb, null: false, default: {}
  end
end
