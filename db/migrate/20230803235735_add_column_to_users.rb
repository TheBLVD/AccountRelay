class AddColumnToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :local, :boolean, default: false
  end
end
