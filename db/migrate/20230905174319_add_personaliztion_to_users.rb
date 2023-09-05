class AddPersonaliztionToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :personalize, :boolean, default: false
  end
end
