require "spec_helper"

describe Detour::DefinedGroup do
  subject { Detour::DefinedGroup.new(:foo, ->{}) }
  it { should respond_to :name }
  it { should respond_to :test }

  describe "#test" do
    before do
      @group = Detour::DefinedGroup.new :foo, ->(arg) { arg == 1 }
    end

    it "tests with the passed block" do
      @group.test(1).should be_true
      @group.test(2).should be_false
    end
  end
end
