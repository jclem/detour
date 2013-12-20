require "spec_helper"

describe Detour::ActsAsFlaggable do
  subject { User.new }

  it { should have_many :flaggable_flags }
  it { should have_many :opt_out_flags }
  it { should have_many(:features).through(:flaggable_flags) }

  it "includes Detour::Flaggable" do
    subject.class.ancestors.should include Detour::Flaggable
  end

  describe "#acts_as_flaggable" do
    describe "Detour::Feature associations" do
      subject { Detour::Feature.new }
      it { should have_one(:users_percentage_flag).class_name("Detour::PercentageFlag").dependent(:destroy) }
      it { should allow_mass_assignment_of(:users_percentage_flag_attributes) }
      it { should accept_nested_attributes_for(:users_percentage_flag) }
    end

    context "when given a :find_by parameter" do
      class Foo < ActiveRecord::Base
        acts_as_flaggable find_by: :email
      end

      it "sets the appropriate class variable on the class" do
        Foo.instance_variable_get("@detour_flaggable_find_by").should eq :email
      end
    end

    context "when not given a :find_by parameter" do
      it "uses the default :id value for flaggable_find_by" do
        User.instance_variable_get("@detour_flaggable_find_by").should eq :id
      end
    end
  end
end
