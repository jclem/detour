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

  def destroy
    @feature = Detour::Feature.find(params[:id])
    @feature.destroy
    flash[:notice] = "Feature #{@feature.name} has been deleted."
    redirect_to flags_path(params[:flaggable_type])
  end
end
