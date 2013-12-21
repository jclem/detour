require "spec_helper"

describe Detour::FlagInFlagsController do
  routes { Detour::Engine.routes }

  describe "GET #index" do
    let(:flag) { create :flag_in_flag }

    before do
      get :index, feature_name: flag.feature.name, flaggable_type: "users"
    end

    it "assigns the flag-in flags" do
      assigns(:flags).should eq [flag]
    end

    it "renders the index template" do
      response.should render_template :index
    end
  end
end
