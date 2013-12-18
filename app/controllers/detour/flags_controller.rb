class Detour::FlagsController < Detour::ApplicationController
  def index
    @features = Detour::Feature.all_with_lines
  end
end
