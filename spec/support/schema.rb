require "generators/templates/migration"

ActiveRecord::Schema.define do
  self.verbose = false

  ActiveRecordRolloutMigration.migrate(:up)

  create_table :users, force: true do |t|
    t.timestamps
  end

  create_table :organizations, force: true do |t|
    t.timestamps
  end
end
