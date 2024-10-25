class CreateFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :follows do |t|
      t.integer :account_id, null: false
      t.integer :target_account_id, null: false

      t.timestamps null: false
    end

    add_index :follows, %i[account_id target_account_id], unique: true
  end
end
