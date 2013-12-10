class SetupActiveRecordRollout < ActiveRecord::Migration
  def change
    create_table :active_record_rollout_features do |t|
      t.string :name
      t.integer :failure_count, default: 0
      t.timestamps
    end

    add_index :active_record_rollout_features, :name, unique: true

    create_table :active_record_rollout_flags do |t|
      t.string  :type
      t.integer :feature_id
      t.integer :flaggable_id
      t.string  :flaggable_type
      t.string  :group_name
      t.integer :percentage
      t.timestamps
    end

    add_index :active_record_rollout_flags, :type
    add_index :active_record_rollout_flags, :feature_id
  end
end
