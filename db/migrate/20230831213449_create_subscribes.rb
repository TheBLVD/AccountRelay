class CreateSubscribes < ActiveRecord::Migration[6.1]
  def change
    create_table :subscribes, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, on_delete: :cascade
      t.references :channel, null: false, foreign_key: true, type: :uuid, on_delete: :cascade

      t.timestamps
    end
  end
end
