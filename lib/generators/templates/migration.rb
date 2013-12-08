class ActiveRecordRolloutMigration < ActiveRecord::Migration
  def change
    create_table :active_record_rollouts do |t|
      t.string :name
      t.timestamps
    end

    add_index :active_record_rollouts, :name, unique: true

    create_table :active_record_rollout_flags do |t|
      t.integer :rollout_id
      t.integer :percentage
      t.string  :percentage_type
      t.integer :flag_subject_id
      t.string  :flag_subject_type
      t.timestamps
    end

    add_index :active_record_rollout_flags, :rollout_id
    add_index :active_record_rollout_flags, :percentage
    add_index :active_record_rollout_flags, :flag_subject_id
    add_index :active_record_rollout_flags, :flag_subject_type
  end
end
