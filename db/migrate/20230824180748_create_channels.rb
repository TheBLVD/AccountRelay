class CreateChannels < ActiveRecord::Migration[6.1]
  def change
    create_table :channels, id: :uuid do |t|
      t.string :title
      t.text :description
      t.boolean :hidden, default: true
      t.references :owner, null: false, foreign_key: { to_table: :users }, type: :uuid

      t.timestamps
    end
  end
end
