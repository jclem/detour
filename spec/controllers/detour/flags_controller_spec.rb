require "spec_helper"

describe Detour::FlagsController do
  routes { Detour::Engine.routes }

  describe "GET #index" do
    before do
      Detour.config.grep_dirs = ["spec/dummy/app/**/*.{rb,erb}"]
      get :index, flaggable_type: "user"
    end

    it "assigns every feature with lines" do
      assigns(:features).collect(&:name).should eq Detour::Feature.with_lines.collect(&:name)
    end

    it "renders the 'index' template" do
      response.should render_template "index"
    end
  end
end
