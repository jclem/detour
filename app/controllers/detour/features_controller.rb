class Detour::FeaturesController < Detour::ApplicationController
  def create
    @feature = Detour::Feature.new(params[:feature])

    if @feature.save
      flash[:notice] = "Your feature has been successfully created."
      render :success
    else
      render :error
    end
  end
end
