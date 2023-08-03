class AddColumnDomainIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :domain_id, :string
  end
end
