class Detour::GroupsController < Detour::ApplicationController
  def index
    @groups = Detour::Group.all
  end
end
