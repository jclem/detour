namespace :rollout do
  desc "Activate a feature for a record"
  task :activate_record, [:feature, :record_type, :record_id] => :environment do |task, args|
    record = args[:record_type].constantize.find args[:record_id]
    ActiveRecord::Rollout::Feature.add_record_to_feature record, args[:feature]
  end

  desc "Deactivate a feature for a record"
  task :deactivate_record, [:feature, :record_type, :record_id] => :environment do |task, args|
    record = args[:record_type].constantize.find args[:record_id]
    ActiveRecord::Rollout::Feature.remove_record_from_feature record, args[:feature]
  end

  desc "Opt a record out of a feature"
  task :opt_out_record, [:feature, :record_type, :record_id] => :environment do |task, args|
    record = args[:record_type].constantize.find args[:record_id]
    ActiveRecord::Rollout::Feature.opt_record_out_of_feature record, args[:feature]
  end

  desc "Remove an opt out of a record from a feature"
  task :un_opt_out_record, [:feature, :record_type, :record_id] => :environment do |task, args|
    record = args[:record_type].constantize.find args[:record_id]
    ActiveRecord::Rollout::Feature.un_opt_record_out_of_feature record, args[:feature]
  end

  desc "Activate a feature for a group"
  task :activate_group, [:feature, :group_type, :group_name] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.add_group_to_feature args[:group_type], args[:group_name], args[:feature]
  end

  desc "Deactivate a feature for a group"
  task :deactivate_group, [:feature, :group_type, :group_name] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.remove_group_from_feature args[:group_type], args[:group_name], args[:feature]
  end

  desc "Activate a feature for a percentage"
  task :activate_percentage, [:feature, :percentage_type, :percentage] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.add_percentage_to_feature args[:percentage_type], args[:percentage].to_i, args[:feature]
  end

  desc "Deactivate a feature for a percentage"
  task :deactivate_percentage, [:feature, :percentage_type] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.remove_percentage_from_feature args[:percentage_type], args[:feature]
  end
end
