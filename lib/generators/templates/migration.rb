class ActiveRecordRolloutMigration < ActiveRecord::Migration
  def change
    create_table :active_record_rollouts do |t|
      t.string :name
      t.timestamps
    end

    create_table :active_record_rollout_flags do |t|
      t.integer :rollout_id
      t.timestamps
    end

    add_index :active_record_rollout_flags, :rollout_id
  end
end
