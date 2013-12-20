require "spec_helper"

describe Detour::FlagsController do
  routes { Detour::Engine.routes }

  describe "GET #index" do
    before do
      Detour.config.grep_dirs = ["spec/dummy/app/**/*.{rb,erb}"]
      get :index, flaggable_type: "users"
    end

    it "assigns every feature with lines" do
      assigns(:features).collect(&:name).should eq Detour::Feature.with_lines.collect(&:name)
    end

    it "renders the 'index' template" do
      response.should render_template "index"
    end

    context "when the type is not defined" do
      it "raisese a 404" do
        expect { get :index, flaggable_type: "user" }.to raise_error ActionController::RoutingError
      end
    end
  end

  describe "POST #update" do
    it "assigns every feature with lines" do
      post :update, flaggable_type: "users"
      assigns(:features).collect(&:name).should eq Detour::Feature.with_lines.collect(&:name)
    end

    context "when the save is successful" do
      let!(:feature) { create :feature, name: "foo_feature" }

      before do
        post :update, flaggable_type: "users", features: {
          foo_feature: {
            users_percentage_flag_attributes: { percentage: 50 }
          }
        }
      end

      it "saves the flags" do
        feature.users_percentage_flag.percentage.should eq 50
      end

      it "redirects to the flags path" do
        response.should redirect_to flags_path
      end

      it "sets a flags message" do
        flash[:notice].should eq "Your flags have been successfully updated."
      end
    end

    context "when the save is unsuccessful" do
      let!(:feature) { create :feature, name: "foo_feature" }

      before do
        post :update, flaggable_type: "users", features: {
          foo_feature: {
            users_percentage_flag_attributes: { percentage: "foo" }
          }
        }
      end

      it "does not save anything" do
        feature.users_percentage_flag.should_not be_persisted
      end

      it "renders the index template" do
        response.should render_template "index"
      end
    end
  end
end
