class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :username
      t.string :domain
      t.references :instance, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
