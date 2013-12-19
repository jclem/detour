class Detour::FlagsController < Detour::ApplicationController
  def index
    @features = Detour::Feature.with_lines
  end
end
