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

  describe "GET #show" do
    let!(:group) { create :group }

    before do
      get :show, id: group.to_param
    end

    it "assigns the groups" do
      assigns(:group).should eq group
    end

    it "renders the show template" do
      response.should render_template "groups/show"
    end
  end
end
