class SetupDetour < ActiveRecord::Migration
  def change
    execute "CREATE EXTENSION IF NOT EXISTS hstore"

    create_table :detour_features do |t|
      t.string :name
      t.integer :failure_count, default: 0
      t.timestamps
    end

    add_index :detour_features, :name, unique: true

    create_table :detour_flags do |t|
      t.string  :type
      t.integer :feature_id
      t.integer :flaggable_id
      t.string  :flaggable_type
      t.string  :group_name
      t.integer :percentage
      t.timestamps
    end

    add_index :detour_flags, :type
    add_index :detour_flags, :feature_id
    add_index :detour_flags,
      [:type, :feature_id, :flaggable_type, :flaggable_id],
      name: "flag_type_feature_flaggable_type_id"
    add_index :detour_flags,
      [:type, :feature_id, :flaggable_type],
    name: "flag_type_feature_flaggable_type"
  end
end
