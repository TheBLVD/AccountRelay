class UpdateDomainIdNonNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:users, :domain_id, false)
  end
end
