class Detour::GroupsController < Detour::ApplicationController
  def index
    @groups = Detour::Group.all
  end

  def show
    @group = Detour::Group.find(params[:id])
  end

  def create
    @group = Detour::Group.new(params[:group])

    if @group.save
      flash[:notice] = "Your group has been successfully created."
      render "detour/shared/success"
    else
      @model = @group
      render "detour/shared/error"
    end
  end

  def update
    @group = Detour::Group.find(params[:id])

    if @group.update_attributes(params[:group])
      flash[:notice] = "Your group has been successfully updated."
      redirect_to group_path @group
    else
      render :show
    end
  end
end
