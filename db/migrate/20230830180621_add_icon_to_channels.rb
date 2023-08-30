class AddIconToChannels < ActiveRecord::Migration[6.1]
  def change
    add_column :channels, :icon, :string, default: "\u{f0e0}"
  end
end
