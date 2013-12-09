class SetupActiveRecordRollout < ActiveRecord::Migration
  def change
    create_table :active_record_rollout_features do |t|
      t.string :name
      t.integer :failure_count, default: 0
      t.timestamps
    end

    add_index :active_record_rollout_features, :name, unique: true

    create_table :active_record_rollout_flags do |t|
      t.integer :feature_id
      t.string  :group_type
      t.string  :group_name
      t.integer :percentage
      t.string  :percentage_type
      t.integer :flag_subject_id
      t.string  :flag_subject_type
      t.timestamps
    end

    add_index :active_record_rollout_flags, :feature_id
    add_index :active_record_rollout_flags, :group_type
    add_index :active_record_rollout_flags, :percentage_type
    add_index :active_record_rollout_flags, :percentage
    add_index :active_record_rollout_flags, [:flag_subject_id, :flag_subject_type], name: :flag_subject_index

    create_table :active_record_rollout_opt_outs do |t|
      t.integer :feature_id
      t.integer :opt_out_subject_id
      t.string  :opt_out_subject_type
      t.timestamps
    end

    add_index :active_record_rollout_opt_outs, [:opt_out_subject_id, :opt_out_subject_type], name: :opt_out_subject_index
  end
end
