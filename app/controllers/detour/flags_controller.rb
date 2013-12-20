class Detour::FlagsController < Detour::ApplicationController
  before_filter :ensure_flaggable_type_exists

  def index
    @features = Detour::Feature.includes("#{params[:flaggable_type]}_percentage_flag").with_lines
  end

  def update
    @features = Detour::Feature.includes("#{params[:flaggable_type]}_percentage_flag").with_lines

    Detour::Feature.transaction do |transaction|
      @features.map do |feature|
        feature.update_attributes params[:features][feature.name]
      end

      if @features.any? { |feature| feature.errors.any? }
        render :index
        raise ActiveRecord::Rollback
      else
        flash[:notice] = "Your flags have been successfully updated."
        redirect_to flags_path
      end
    end
  end

  private

  def ensure_flaggable_type_exists
    unless Detour.config.flaggable_types.map(&:tableize).include? params[:flaggable_type]
      raise ActionController::RoutingError.new("Not Found")
    end
  end
end
