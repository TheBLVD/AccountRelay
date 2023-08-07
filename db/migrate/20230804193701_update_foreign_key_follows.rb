class UpdateForeignKeyFollows < ActiveRecord::Migration[6.1]
  def change
    # remove the old foreign_key
    remove_foreign_key :follows, :users
    remove_foreign_key :follows, :users

    # add the new foreign_key
    add_foreign_key :follows, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :follows, :users, column: :target_user_id, on_delete: :cascade
  end
end
