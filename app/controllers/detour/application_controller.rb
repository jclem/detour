class Detour::ApplicationController < ActionController::Base
  def index
  end

  private

  def ensure_flaggable_type_exists
    unless Detour.config.flaggable_types.map(&:tableize).include? params[:flaggable_type]
      raise ActionController::RoutingError.new("Not Found")
    end
  end
end
