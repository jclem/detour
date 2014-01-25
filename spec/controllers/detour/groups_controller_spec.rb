require "spec_helper"

describe Detour::GroupsController do
  routes { Detour::Engine.routes }

  describe "GET #index" do
    let!(:group) { create :group }

    before do
      get :index
    end

    it "assigns the groups" do
      assigns(:groups).should eq [group]
    end

    it "renders the index template" do
      response.should render_template "groups/index"
    end
  end
end
