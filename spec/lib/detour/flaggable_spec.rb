require "spec_helper"

describe Detour::Flaggable do
  subject { User.new }

  describe "#flaggable_find!" do
    context "when a non-default find_by is not specified" do
      it "finds by id" do
        User.should_receive(:find_by_id!).with(1)
        User.flaggable_find!(1)
      end
    end

    context "when a non-default find_by is not specified" do
      class Foo < ActiveRecord::Base
        acts_as_flaggable find_by: :email
      end

      it "finds by id" do
        Foo.should_receive(:find_by_email!).with("user@example.com")
        Foo.flaggable_find!("user@example.com")
      end
    end
  end

  describe "#has_feature?" do
    let(:user)    { create :user }
    let(:feature) { create :feature }

    it "memoizes found features" do
      Detour::Feature.stub(:find_by_name) { feature }
      feature.flag_in_flags.create(flaggable: user)

      feature.should_receive(:match?).with(user).and_return(true)
      user.has_feature?(feature.name)

      feature.should_not_receive(:match?).with(user)
      user.has_feature?(feature.name)
    end

    context "when the user is not flagged in" do
      it "returns false" do
        user.has_feature?(feature.name).should be_false
      end
    end

    context "when the user is flagged in" do
      context "and the user is opted out" do
        before do
          feature.flag_in_flags.create(flaggable: user)
          feature.opt_out_flags.create(flaggable: user)
        end

        it "returns false" do
          user.has_feature?(feature.name).should be_false
        end
      end

      context "and the user is not opted out" do
        context "and the user is flagged in individually" do
          before do
            feature.flag_in_flags.create(flaggable: user)
          end

          it "returns true" do
            user.has_feature?(feature.name).should be_true
          end
        end

        context "and the user is flagged in as a percentage" do
          before do
            feature.percentage_flags.create(flaggable_type: "User", percentage: 100)
          end

          it "returns true" do
            user.has_feature?(feature.name).should be_true
          end
        end

        context "and the user is flagged in via a group" do
          before do
            Detour.config.define_user_group "name_foo" do |_user|
              _user.name == user.name
            end

            feature.defined_group_flags.create(flaggable_type: "User", group_name: "name_foo")
          end

          it "returns true" do
            user.has_feature?(feature.name).should be_true
          end
        end
      end
    end
  end
end
