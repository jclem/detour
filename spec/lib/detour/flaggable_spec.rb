require "spec_helper"

describe Detour::Flaggable do
  subject { create :user }

  describe "#detour_features" do
    let(:feature1)       { create :feature }
    let(:feature2)       { create :feature }
    let(:feature3)       { create :feature }
    let(:feature4)       { create :feature }
    let(:feature5)       { create :feature }
    let(:membership)     { create :membership, member: subject }
    let(:defined_group)  { Detour::DefinedGroup.new "foo",  ->(user){true} }
    let(:defined_group2) { Detour::DefinedGroup.new "foo2", ->(user){false} }

    before do
      Detour.config.defined_groups["User"] = { foo: defined_group }
      create :flag_in_flag, flaggable: subject, feature: feature1
      create :percentage_flag, flaggable_type: "User", feature: feature2
      create :database_group_flag, flaggable_type: "User", feature: feature3, group: membership.group
      create :database_group_flag, flaggable_type: "User", feature: feature4, group: membership.group
      create :opt_out_flag, flaggable: subject, feature: feature4
      create :defined_group_flag, flaggable_type: "User", feature: feature5, group_name: "foo"
      create :defined_group_flag, flaggable_type: "User", feature: feature5, group_name: "foo2"
    end

    it "finds every feature for a record" do
      subject.detour_features.sort.should eq [feature1, feature2, feature3, feature5].sort
    end

    it "is memoized" do
      subject.detour_features
      Detour::Feature.stub(:joins) { raise "I was called" }
      subject.detour_features
    end
  end

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
