require "indefinite_article"

class Detour::FlaggableFlagsController < Detour::ApplicationController
  include Detour::FlaggableFlagsHelper

  before_filter :ensure_flaggable_type_exists
  before_filter :ensure_flag_type_exists

  def index
    @feature = Detour::Feature.where(name: params[:feature_name]).first_or_create!
  end

  def update
    @feature = Detour::Feature.find_by_name!(params[:feature_name])

    if @feature.update_attributes(params[:feature])
      flash[:notice] = "Your #{flag_noun.pluralize} have been updated"
      redirect_to flaggable_flags_path flag_type: params[:flag_type], feature_name: params[:feature_name], flaggable_type: params[:flaggable_type]
    else
      render :index
    end
  end

  private

  def ensure_flag_type_exists
    unless %w[flag-ins opt-outs].include? params[:flag_type]
      raise ActionController::RoutingError.new("Not Found")
    end
  end
end
