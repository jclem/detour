require "spec_helper"

describe Detour::FlagsController do
  routes { Detour::Engine.routes }

  describe "GET #index" do
    before do
      get :index, flaggable_type: "user"
    end

    it "assigns every feature with lines" do
      assigns(:features).should eq Detour::Feature.all_with_lines
    end

    it "renders the 'index' template" do
      response.should render_template "index"
    end
  end
end
