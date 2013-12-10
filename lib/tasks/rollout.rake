namespace :rollout do
  desc "Activate a feature for a record"
  task :activate, [:feature, :flaggable_type, :flaggable_id] => :environment do |task, args|
    record = args[:flaggable_type].constantize.find args[:flaggable_id]
    ActiveRecord::Rollout::Feature.add_record_to_feature record, args[:feature]
  end

  desc "Deactivate a feature for a record"
  task :deactivate, [:feature, :flaggable_type, :flaggable_id] => :environment do |task, args|
    record = args[:flaggable_type].constantize.find args[:flaggable_id]
    ActiveRecord::Rollout::Feature.remove_record_from_feature record, args[:feature]
  end

  desc "Opt a record out of a feature"
  task :opt_out, [:feature, :flaggable_type, :flaggable_id] => :environment do |task, args|
    record = args[:flaggable_type].constantize.find args[:flaggable_id]
    ActiveRecord::Rollout::Feature.opt_record_out_of_feature record, args[:feature]
  end

  desc "Remove an opt out of a record from a feature"
  task :un_opt_out, [:feature, :flaggable_type, :flaggable_id] => :environment do |task, args|
    record = args[:flaggable_type].constantize.find args[:flaggable_id]
    ActiveRecord::Rollout::Feature.un_opt_record_out_of_feature record, args[:feature]
  end

  desc "Activate a feature for a group"
  task :activate_group, [:feature, :flaggable_type, :group_name] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.add_group_to_feature args[:flaggable_type], args[:group_name], args[:feature]
  end

  desc "Deactivate a feature for a group"
  task :deactivate_group, [:feature, :flaggable_type, :group_name] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.remove_group_from_feature args[:flaggable_type], args[:group_name], args[:feature]
  end

  desc "Activate a feature for a percentage"
  task :activate_percentage, [:feature, :flaggable_type, :percentage] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.add_percentage_to_feature args[:flaggable_type], args[:percentage].to_i, args[:feature]
  end

  desc "Deactivate a feature for a percentage"
  task :deactivate_percentage, [:feature, :flaggable_type] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.remove_percentage_from_feature args[:flaggable_type], args[:feature]
  end
end
