require "indefinite_article"

class Detour::FlaggableFlagsController < Detour::ApplicationController
  include Detour::FlaggableFlagsHelper

  before_filter :ensure_flaggable_type_exists

  def index
    @feature = Detour::Feature.find_by_name!(params[:feature_name])
  end

  def update
    @feature = Detour::Feature.find_by_name!(params[:feature_name])

    if @feature.update_attributes(params[:feature])
      flash[:notice] = "Your #{flag_noun.pluralize} have been updated"
      redirect_to send("#{flag_type}_flags_path", feature_name: params[:feature_name], flaggable_type: params[:flaggable_type])
    else
      render :index
    end
  end
end
