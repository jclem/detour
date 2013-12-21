require "spec_helper"

describe Detour::FeaturesController do
  routes { Detour::Engine.routes }

  describe "POST #create" do
    before do
      post :create, format: :js, feature: feature_params
    end

    context "when successful" do
      let(:feature_params) { { name: "foo_feature" } }

      it "sets a flash message" do
        flash[:notice].should eq "Your feature has been successfully created."
      end

      it "renders the success template" do
        response.should render_template "success"
      end
    end

    context "when unsuccessful" do
      let(:feature_params) { { name: "" } }

      it "renders the errors template" do
        response.should render_template "error"
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:feature) { create :feature }

    before do
      delete :destroy, format: :js, id: feature.id, flaggable_type: :users
    end

    it "destroys the feature" do
      Detour::Feature.find_by_id(feature.id).should be_nil
    end

    it "displays a flash message" do
      flash[:notice].should eq "Feature #{feature.name} has been deleted."
    end

    it "renders the destroyed template" do
      response.should redirect_to flags_path(:users)
    end
  end
end
