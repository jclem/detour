class Detour::FlagForm
  def initialize(flaggable_type)
    @flaggable_type = flaggable_type
  end

  def features
    @features ||= Detour::Feature.includes("#{@flaggable_type}_percentage_flag", "#{@flaggable_type}_group_flags").with_lines
  end

  def group_names
    return @group_names if @group_names
    all_names           = features.collect { |feature| feature.send("#{@flaggable_type}_group_flags").collect(&:group_name) }.flatten.map(&:to_s).uniq
    defined_group_names = Detour.config.defined_groups.fetch(@flaggable_type.classify, {}).keys.map(&:to_s)
    @group_names        = (all_names | defined_group_names).sort
  end

  def group_flags_for(feature)
    group_names.map do |group_name|
      flags = feature.send("#{@flaggable_type}_group_flags")
      flags.detect { |flag| flag.group_name == group_name } || flags.new(group_name: group_name)
    end
  end

  def update_attributes(params)
    Detour::Feature.transaction do |transaction|
      features.map do |feature|
        feature_params = params[:features][feature.name]
        next unless feature_params

        check_percentage_flag_for_deletion(feature, feature_params)
        set_group_flag_params(feature, feature_params)
        feature.update_attributes feature_params
      end

      if features.any? { |feature| feature.errors.any? }
        raise ActiveRecord::Rollback
      else
        true
      end
    end
  end

  private

  def check_percentage_flag_for_deletion(feature, params)
    key         = :"#{@flaggable_type}_percentage_flag_attributes"
    flag        = feature.send("#{@flaggable_type}_percentage_flag")
    flag_params = params[key]

    if flag.present? && flag_params[:percentage].blank?
      feature.users_percentage_flag = nil
    end
  end

  def set_group_flag_params(feature, params)
    key          = :"#{@flaggable_type}_group_flags_attributes"
    flags_params = params[key]
    params.delete key

    group_flags_for(feature).each do |flag|
      if flags_params[flag.group_name]["to_keep"] == "1"
        flag.to_keep = "1"
      else
        flag.mark_for_destruction
      end
    end
  end
end
