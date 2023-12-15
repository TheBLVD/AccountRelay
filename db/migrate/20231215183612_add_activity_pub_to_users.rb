class AddActivityPubToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :inbox_url, :string, default: ''
    add_column :users, :outbox_url, :string, default: ''
    add_column :users, :shared_inbox_url, :string, default: ''
    add_column :users, :followers_url, :string, default: ''
    add_column :users, :uri, :string, default: ''
    add_column :users, :url, :string
    add_column :users, :actor_type, :string
    add_column :users, :featured_collection_url, :string
    add_column :users, :note, :string, default: ''
    add_column :users, :fields, :jsonb, default: {}
    add_column :users, :avatar_remote_url, :string
    add_column :users, :public_key, :text, default: ''
    add_column :users, :protocol, :int, default: 0
  end
end
