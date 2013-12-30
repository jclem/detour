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

  describe "POST #create" do
    let!(:user)    { create :user }
    let(:feature) { create :feature }

    context "when creating multiple flag-ins" do
      let!(:user2) { create :user, email: "another@example.com" }

      before do
        post :create, feature_name: feature.name, flaggable_type: user.class.table_name, ids: ids, format: :js
      end

      context "when successful" do
        let(:ids) { [user.id.to_s, user2.id.to_s].join(",") }

        it "creates the flag-in" do
          feature.users_flag_ins.collect(&:flaggable).should eq [user, user2]
        end

        it "sets a flash message" do
          flash[:notice].should eq "#{user.class.to_s.pluralize} #{user.id}, #{user2.id} have been flagged in to #{feature.name}"
        end
      end

      context "when unsuccessful" do
        let(:ids) { "foo" }

        it "renders the errors template" do
          response.should render_template "error"
        end
      end

      context "when creating a single flag-in" do
        before do
          post :create, feature_name: feature.name, flaggable_type: user.class.table_name, ids: ids, format: :js
        end

        context "when successful" do
          let(:ids) { user.id.to_s }

          it "creates the flag-in" do
            feature.users_flag_ins.collect(&:flaggable).should eq [user]
          end

          it "sets a flash message" do
            flash[:notice].should eq "#{user.class} #{user.id} has been flagged in to #{feature.name}"
          end
        end

        context "when the flaggable can't be found" do
          let(:ids) { "foo" }

          it "renders the errors template" do
            response.should render_template "error"
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:flag) { create :flag_in_flag }

    before do
      delete :destroy, feature_name: flag.feature.name, flaggable_type: "users", id: flag.id
    end

    it "destroys the flag" do
      expect { flag.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "sets a flash message" do
      flash[:notice].should eq "#{flag.feature.name} flag-in for User #{flag.flaggable.id} has been deleted."
    end

    it "redirects to the flag-ins index" do
      response.should redirect_to flag_in_flags_path flag.feature.name, "users"
    end
  end
end
