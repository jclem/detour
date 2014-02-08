require "spec_helper"

describe Detour::Configuration do
  describe ".define_group_for_class" do
    let(:block) { Proc.new { "foo!" } }

    before do
      subject.send :define_group_for_class, "User", "user_id_1", &block
    end

    it "defines a group for the given class" do
      subject.defined_groups["User"].values[0].name.should eq "user_id_1"
    end

    it "assigns the test for the group" do
      subject.defined_groups["User"].values[0].test(1).should eq "foo!"
    end
  end

  describe ".feature_search_regex=" do
    context "when given a regex" do
      it "sets the feature search regex" do
        subject.feature_search_regex = /foo/
        subject.feature_search_regex.should eq /foo/
      end
    end

    context "when not given a regex" do
      it "raises an exception" do
        expect { subject.feature_search_regex = "string" }.to raise_error "Feature search regex must be an instance of Regexp"
      end
    end
  end

  describe ".define_{klass}_group" do
    let(:block) { Proc.new {} }
    it "defines a group for the given class" do
      subject.should_receive(:define_group_for_class).with("User", :id_is_1)
      subject.define_user_group :id_is_1, block
    end
  end
end
