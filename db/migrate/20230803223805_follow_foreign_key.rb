class FollowForeignKey < ActiveRecord::Migration[6.1]
  def change
    remove_column :follows, :target_user_id
    remove_column :follows, :user_id
    # need to be UUID
    add_column :follows, :user_id, :uuid, null: false
    add_column :follows, :target_user_id, :uuid, null: false
    # then and maybe then it will work
    add_foreign_key :follows, :users, column: :user_id
    add_foreign_key :follows, :users, column: :target_user_id
  end
end
