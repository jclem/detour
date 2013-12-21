class Detour::FlagInFlagsController < Detour::ApplicationController
  before_filter :ensure_flaggable_type_exists

  def index
    feature = Detour::Feature.find_by_name!(feature_name)
    @flags  = feature.flag_in_flags.where(flaggable_type: flaggable_class.to_s)
  end

  def destroy
    feature = Detour::Feature.find_by_name!(feature_name)
    @flag   = feature.flag_in_flags.find(params[:id])
    @flag.destroy
    flash[:notice] = "#{feature_name} flag-in for #{flaggable_class} #{@flag.flaggable.send flaggable_class.detour_flaggable_find_by} has been deleted."
    redirect_to flag_in_flags_path feature.name, flaggable_type
  end

  private

  def feature_name
    params[:feature_name]
  end
  helper_method :feature_name

  def flaggable_type
    params[:flaggable_type]
  end
  helper_method :flaggable_type

  def flaggable_class
    flaggable_type.classify.constantize
  end
  helper_method :flaggable_class
end
