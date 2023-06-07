class AddUuidToInstances < ActiveRecord::Migration[6.1]
  def up
    add_column :instances, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    rename_column :instances, :id, :integer_id
    rename_column :instances, :uuid, :id
    execute 'ALTER TABLE instances drop constraint instances_pkey;'
    execute 'ALTER TABLE instances ADD PRIMARY KEY (id);'

    # Optionally you remove auto-incremented
    # default value for integer_id column
    execute 'ALTER TABLE ONLY instances ALTER COLUMN integer_id DROP DEFAULT;'
    change_column_null :instances, :integer_id, true
    execute 'DROP SEQUENCE IF EXISTS instances_id_seq'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
