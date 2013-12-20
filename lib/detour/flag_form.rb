class Detour::FlagForm
  def initialize(flaggable_type)
    @flaggable_type = flaggable_type
  end

  def features
    @features ||= Detour::Feature.includes("#{@flaggable_type}_percentage_flag").with_lines
  end

  def update_attributes(params)
    Detour::Feature.transaction do |transaction|
      features.map do |feature|
        feature_params = params[:features][feature.name]
        check_percentage_flag_for_deletion(feature, feature_params)
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
end
