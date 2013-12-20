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
        feature.update_attributes params[:features][feature.name]
      end

      if features.any? { |feature| feature.errors.any? }
        raise ActiveRecord::Rollback
      else
        true
      end
    end
  end
end
