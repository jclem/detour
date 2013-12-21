class Detour::FlagInFlagsController < Detour::ApplicationController
  before_filter :ensure_flaggable_type_exists

  def index
    feature = Detour::Feature.find_by_name!(feature_name)
    @flags  = feature.flag_in_flags.where(flaggable_type: flaggable_class.to_s)
  end

  private

  def feature_name
    params[:feature_name]
  end

  def flaggable_type
    params[:flaggable_type]
  end

  def flaggable_class
    flaggable_type.classify.constantize
  end
  helper_method :flaggable_class
end
