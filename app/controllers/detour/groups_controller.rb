class Detour::GroupsController < Detour::ApplicationController
  def index
    @groups = Detour::Group.all
  end

  def show
    @group = Detour::Group.find(params[:id])
  end
end
