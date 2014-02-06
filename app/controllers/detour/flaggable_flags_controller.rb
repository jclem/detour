require "indefinite_article"

class Detour::FlaggableFlagsController < Detour::ApplicationController
  before_filter :ensure_flaggable_type_exists

  def index
    @feature = Detour::Feature.find_by_name!(feature_name)
  end

  def update
    @feature = Detour::Feature.find_by_name!(feature_name)

    if @feature.update_attributes(params[:feature])
      flash[:notice] = "Your #{flag_noun.pluralize} have been updated"
      redirect_to send("#{flag_type}_flags_path", feature_name: feature_name, flaggable_type: flaggable_type)
    else
      render :index
    end
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

  def flag_type
    request.path.split("/")[2].underscore.singularize
  end
  helper_method :flag_type

  def flag_verb
    flag_type == "flag_in" ? "flagged in to" : "opted out of"
  end
  helper_method :flag_verb

  def flag_noun
    flag_type.dasherize
  end
  helper_method :flag_noun
end
