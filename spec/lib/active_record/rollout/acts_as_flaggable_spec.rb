require "spec_helper"

describe ActiveRecord::Rollout::ActsAsFlaggable do
  subject { User.new }

  it { should have_many :flaggable_flags }
  it { should have_many :opt_out_flags }
  it { should have_many(:features).through(:flaggable_flags) }

  it "includes ActiveRecord::Rollout::Flaggable" do
    subject.class.ancestors.should include ActiveRecord::Rollout::Flaggable
  end

  describe "#acts_as_flaggable" do
    context "when given a :find_by parameter" do
      class Foo < ActiveRecord::Base
        acts_as_flaggable find_by: :email
      end

      it "sets the appropriate class variable on the class" do
        Foo.instance_variable_get("@active_record_rollout_flaggable_find_by").should eq :email
      end
    end

    context "when not given a :find_by parameter" do
      it "uses the default :id value for flaggable_find_by" do
        User.instance_variable_get("@active_record_rollout_flaggable_find_by").should eq :id
      end
    end
  end
end
