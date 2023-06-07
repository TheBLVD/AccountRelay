class CreateInstances < ActiveRecord::Migration[6.1]
  def change
    create_table :instances do |t|
      t.string :name
      t.text :description
      t.string :url
      t.string :key

      t.timestamps
    end
  end
end
