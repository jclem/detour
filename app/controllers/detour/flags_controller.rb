class Detour::FlagsController < Detour::ApplicationController
  before_filter :ensure_flaggable_type_exists

  def index
    @features = Detour::Feature.with_lines
  end

  private

  def ensure_flaggable_type_exists
    unless Detour.config.flaggable_types.map(&:tableize).include? params[:flaggable_type]
      raise ActionController::RoutingError.new("Not Found")
    end
  end
end
