class SetupDetour < ActiveRecord::Migration
  def change
    create_table :detour_features do |t|
      t.string :name
      t.integer :failure_count, default: 0
      t.text    :flag_in_counts, default: "{}"
      t.text    :opt_out_counts, default: "{}"
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

    create_table :detour_groups do |t|
      t.string :name
      t.timestamps
    end

    create_table :detour_memberships do |t|
      t.integer :group_id
      t.string  :member_type
      t.integer :member_id
      t.timestamps
    end

    add_index :detour_memberships, [:group_id, :member_type, :member_id],
      name: :detour_memberships_membership_index,
      unique: true
  end
end
