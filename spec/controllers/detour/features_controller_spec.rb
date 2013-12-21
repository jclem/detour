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
end
