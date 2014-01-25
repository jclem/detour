require "spec_helper"

describe Detour::MembershipsController do
  routes { Detour::Engine.routes }

  describe "POST #create" do
    let(:group) { create :group }

    before do
      User.instance_variable_set "@detour_flaggable_find_by", :email
      post :create, format: :js, membership: membership_params
    end

    context "when successful" do
      let(:user)  { create :user }
      let(:membership_params) { { group_id: group.id, member_type: "User", member_id: user.email } }

      it "sets a flash message" do
        flash[:notice].should eq "A new member has been added to the group."
      end

      it "renders the success template" do
        response.should render_template "success"
      end
    end

    context "when unsuccessful" do
      let(:membership_params) { { group_id: group.id, member_type: "User", member_id: "not found" } }

      it "renders the errors template" do
        response.should render_template "error"
      end
    end
  end
end

