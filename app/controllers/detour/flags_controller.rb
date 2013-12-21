class Detour::FlagsController < Detour::ApplicationController
  before_filter :ensure_flaggable_type_exists

  def index
    @flag_form = Detour::FlagForm.new(params[:flaggable_type])
  end

  def update
    @flag_form = Detour::FlagForm.new(params[:flaggable_type])

    if @flag_form.update_attributes(params)
      flash[:notice] = "Your flags have been successfully updated."
      redirect_to flags_path
    else
      render :index
    end
  end
end
