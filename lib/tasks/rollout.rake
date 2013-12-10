namespace :rollout do
  desc "Create a feature"
  task :create, [:feature] => :environment do |task, args|
    ActiveRecord::Rollout::Feature.find_or_create_by_name! args[:feature]
  end

  desc "Destroy a feature"
  task :destroy, [:feature] => :environment do |task, args|
    feature = ActiveRecord::Rollout::Feature.find_by_name! args[:feature]
    feature.destroy
  end

  desc "Activate a feature for a record"
  task :activate, [:feature, :flaggable_type, :flaggable_id] => :environment do |task, args|
    if args.to_a.length < 3 && ActiveRecord::Rollout::Feature.default_flaggable_class_name
      klass = ActiveRecord::Rollout::Feature.default_flaggable_class_name.constantize
      record_locator = args[:flaggable_type]
    else
      klass = args[:flaggable_type].constantize
      record_locator = args[:flaggable_id]
    end

    record = klass.flaggable_find! record_locator

    ActiveRecord::Rollout::Feature.add_record_to_feature record, args[:feature]
  end

  desc "Deactivate a feature for a record"
  task :deactivate, [:feature, :flaggable_type, :flaggable_id] => :environment do |task, args|
    if args.to_a.length < 3 && ActiveRecord::Rollout::Feature.default_flaggable_class_name
      klass = ActiveRecord::Rollout::Feature.default_flaggable_class_name.constantize
      record_locator = args[:flaggable_type]
    else
      klass = args[:flaggable_type].constantize
      record_locator = args[:flaggable_id]
    end

    record = klass.flaggable_find! record_locator
    ActiveRecord::Rollout::Feature.remove_record_from_feature record, args[:feature]
  end

  desc "Opt a record out of a feature"
  task :opt_out, [:feature, :flaggable_type, :flaggable_id] => :environment do |task, args|
    if args.to_a.length < 3 && ActiveRecord::Rollout::Feature.default_flaggable_class_name
      klass = ActiveRecord::Rollout::Feature.default_flaggable_class_name.constantize
      record_locator = args[:flaggable_type]
    else
      klass = args[:flaggable_type].constantize
      record_locator = args[:flaggable_id]
    end

    record = klass.flaggable_find! record_locator
    ActiveRecord::Rollout::Feature.opt_record_out_of_feature record, args[:feature]
  end

  desc "Remove an opt out of a record from a feature"
  task :un_opt_out, [:feature, :flaggable_type, :flaggable_id] => :environment do |task, args|
    if args.to_a.length < 3 && ActiveRecord::Rollout::Feature.default_flaggable_class_name
      klass = ActiveRecord::Rollout::Feature.default_flaggable_class_name.constantize
      record_locator = args[:flaggable_type]
    else
      klass = args[:flaggable_type].constantize
      record_locator = args[:flaggable_id]
    end

    record = klass.flaggable_find! record_locator
    ActiveRecord::Rollout::Feature.un_opt_record_out_of_feature record, args[:feature]
  end

  desc "Activate a feature for a group"
  task :activate_group, [:feature, :flaggable_type, :group_name] => :environment do |task, args|
    if args.to_a.length < 3 && ActiveRecord::Rollout::Feature.default_flaggable_class_name
      klass = ActiveRecord::Rollout::Feature.default_flaggable_class_name
      group_name = args[:flaggable_type]
    else
      klass = args[:flaggable_type]
      group_name = args[:group_name]
    end

    ActiveRecord::Rollout::Feature.add_group_to_feature klass, group_name, args[:feature]
  end

  desc "Deactivate a feature for a group"
  task :deactivate_group, [:feature, :flaggable_type, :group_name] => :environment do |task, args|
    if args.to_a.length < 3 && ActiveRecord::Rollout::Feature.default_flaggable_class_name
      klass = ActiveRecord::Rollout::Feature.default_flaggable_class_name
      group_name = args[:flaggable_type]
    else
      klass = args[:flaggable_type]
      group_name = args[:group_name]
    end

    ActiveRecord::Rollout::Feature.remove_group_from_feature klass, group_name, args[:feature]
  end

  desc "Activate a feature for a percentage"
  task :activate_percentage, [:feature, :flaggable_type, :percentage] => :environment do |task, args|
    if args.to_a.length < 3 && ActiveRecord::Rollout::Feature.default_flaggable_class_name
      klass = ActiveRecord::Rollout::Feature.default_flaggable_class_name
      percentage = args[:flaggable_type]
    else
      klass = args[:flaggable_type]
      percentage = args[:percentage]
    end

    ActiveRecord::Rollout::Feature.add_percentage_to_feature klass, percentage.to_i, args[:feature]
  end

  desc "Deactivate a feature for a percentage"
  task :deactivate_percentage, [:feature, :flaggable_type] => :environment do |task, args|
    if args.to_a.length < 3 && ActiveRecord::Rollout::Feature.default_flaggable_class_name
      klass = ActiveRecord::Rollout::Feature.default_flaggable_class_name
    else
      klass = args[:flaggable_type]
    end

    ActiveRecord::Rollout::Feature.remove_percentage_from_feature klass, args[:feature]
  end
end
