class AddOnDeleteToSubscribe < ActiveRecord::Migration[6.1]
  def change
    # remove the old foreign_key
    remove_foreign_key :subscribes, :users
    remove_foreign_key :subscribes, :channels

    # readd with with cascade
    add_foreign_key :subscribes, :channels, on_delete: :cascade
    add_foreign_key :subscribes, :users, on_delete: :cascade
  end
end
