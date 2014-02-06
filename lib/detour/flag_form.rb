class Detour::FlagForm
  def initialize(flaggable_type)
    @flaggable_type = flaggable_type.classify.constantize
  end

  def features
    @features ||= Detour::Feature.includes("#{flaggable_collection}_percentage_flag", "#{flaggable_collection}_database_group_flags", "#{flaggable_collection}_defined_group_flags").with_lines
  end

  def errors?
    features.any? { |feature| feature.errors.any? }
  end

  def groups
    @groups ||= (database_groups + defined_groups).sort_by { |group| group.name.downcase }
  end

  def group_flags_for(feature, types = %w[defined database])
    Array.wrap(types).inject([]) do |flags, type|
      flags.concat _group_flags_for(feature, type)
    end.sort_by do |flag|
      flag.group.name.downcase
    end
  end

  def update_attributes(params)
    Detour::Feature.transaction do |transaction|
      features.map do |feature|
        feature_params = params[:features][feature.name]
        next unless feature_params

        check_percentage_flag_for_deletion(feature, feature_params)
        process_group_flags(feature, feature_params)

        feature.assign_attributes feature_params
        feature.save if feature.changed_for_autosave?
      end

      if features.any? { |feature| feature.errors.any? }
        raise ActiveRecord::Rollback
      else
        true
      end
    end
  end

  private

  def _group_flags_for(feature, type)
    send("#{type}_groups").map do |group|
      flags = feature.send("#{flaggable_collection}_#{type}_group_flags")
      if flag = flags.detect { |flag| flag.group.id == group.id } 
        next flag
      else
        if type == "database"
          flags.new(group_id: group.id)
        else
          flags.new(group_name: group.name)
        end
      end
    end
  end

  def check_percentage_flag_for_deletion(feature, params)
    key         = :"#{flaggable_collection}_percentage_flag_attributes"
    flag        = feature.send("#{flaggable_collection}_percentage_flag")
    flag_params = params[key]

    if flag.present? && flag_params[:percentage].blank?
      feature.send("#{flaggable_collection}_percentage_flag").mark_for_destruction
      feature.send("#{flaggable_collection}_percentage_flag=", nil)
    end

    if flag.present? && flag_params[:percentage].to_i == flag.percentage
      params.delete key
    end
  end

  def database_groups
    @database_groups ||= Detour::Group.where(flaggable_type: @flaggable_type)
  end

  def defined_groups
    @defined_groups ||= begin
      (Detour::DefinedGroupFlag.where(flaggable_type: @flaggable_type).map { |flag|
        if flag.group
          flag.group
        else
          Detour::DefinedGroup.new(flag.group_name, ->{})
        end
      } + Detour::DefinedGroup.by_type(@flaggable_type).values).uniq(&:name)
    end
  end

  def flaggable_collection
    @flaggable_type.table_name
  end

  def process_group_flags(feature, params)
    %w[defined database].each do |type|
      key          = :"#{flaggable_collection}_#{type}_group_flags_attributes"
      flags_params = params[key] || {}
      params.delete key

      group_flags_for(feature, type).each do |flag|
        flag.keep_or_destroy(flags_params[flag.group_name])
      end
    end
  end
end
