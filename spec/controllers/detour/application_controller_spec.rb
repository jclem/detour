require "spec_helper"

describe Detour::ApplicationController do
  routes { Detour::Engine.routes }

  describe "GET #index" do
    before do
      get :index
    end

    it "renders the index template" do
      response.should render_template "index"
    end
  end
end
