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

  describe "POST #create" do
    before do
      post :create, format: :js, group: group_params
    end

    context "when successful" do
      let(:group_params) { { name: "Foo Group" } }

      it "sets a flash message" do
        flash[:notice].should eq "Your group has been successfully created."
      end

      it "renders the success template" do
        response.should render_template "success"
      end
    end

    context "when unsuccessful" do
      let(:group_params) { { name: "" } }

      it "renders the errors template" do
        response.should render_template "error"
      end
    end
  end
end
