require "spec_helper"

describe Detour::FlaggableFlagsController do
  routes { Detour::Engine.routes }

  describe "GET #index" do
    let(:flag) { create :flag_in_flag }

    before do
      get :index, feature_name: flag.feature.name, flaggable_type: "users"
    end

    it "assigns the feature" do
      assigns(:feature).should eq flag.feature
    end

    it "renders the index template" do
      response.should render_template :index
    end
  end

  describe "PUT #update" do
    let(:flag) { create :flag_in_flag }

    before do
      put :update, feature_name: flag.feature.name, flaggable_type: "users", feature: flag_params
    end

    context "when successful" do
      let(:user) { create :user }

      let(:flag_params) do
        {
          flag_in_flags_attributes: {
            "1" => { flaggable_type: "User", flaggable_key: user.id, _destroy: 0 }
          }
        }
      end

      it "sets a flash message" do
        flash[:notice].should eq "Your flag-ins have been updated"
      end

      it "redirect to the group" do
        response.should redirect_to flag_in_flags_path(feature_name: flag.feature.name, flaggable_type: "users")
      end
    end

    context "when unsuccessful" do
      let(:flag_params) do
        {
          flag_in_flags_attributes: {
            "1" => { flaggable_type: "User", flaggable_key: nil, _destroy: 0 }
          }
        }
      end

      it "renders the show template" do
        response.should render_template :index
      end
    end
  end
end
