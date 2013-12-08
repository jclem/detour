ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name
    t.timestamps
  end

  create_table :organizations, force: true do |t|
    t.string :name
    t.timestamps
  end
end
