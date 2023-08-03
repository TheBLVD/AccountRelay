class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :username
      t.string :domain
      t.boolean :discoverable
      t.string :display_name

      t.timestamps
    end
  end
end
