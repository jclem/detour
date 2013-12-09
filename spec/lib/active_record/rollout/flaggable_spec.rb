require "spec_helper"

describe ActiveRecord::Rollout::Flaggable do
  subject { User.new }
  it { should have_many :flags }
  it { should have_many :rollouts }
  it { should have_many :opt_outs }

  describe "#rollout?" do
    let(:user) { User.create(name: "foo") }
    let(:rollout) { ActiveRecord::Rollout.create(name: "bar") }

    context "when given a block" do
      context "and the user is flagged in" do
        before do
          rollout.flags.create(flag_subject: user)
        end

        it "calls the block" do
          foo = "foo"
          user.rollout?(:bar) { foo = "bar" }
          foo.should eq "bar"
        end

        context "when the block raises an exception" do
          it "increments the failure_count of the rollout" do
            begin
              user.rollout? :bar do
                raise "This is an exception"
              end
            rescue
              rollout.reload.failure_count.should eq 1
            end
          end

          it "raises the exception" do
            expect do
              user.rollout? :bar do
                raise "This is an exception"
              end
            end.to raise_error "This is an exception"
          end
        end
      end

      context "and the user is not flagged in" do
        it "does not call the block" do
          foo = "foo"
          user.rollout?(:bar) { foo = "bar" }
          foo.should eq "foo"
        end
      end
    end

    context "when the user is not flagged in" do
      it "returns false" do
        user.rollout?(:bar).should be_false
      end
    end

    context "when the user is flagged in" do
      context "and the user is opted out" do
        before do
          rollout.flags.create(flag_subject: user)
          user.opt_outs.create(rollout: rollout)
        end

        it "returns false" do
          user.rollout?(:bar).should be_false
        end
      end

      context "and the user is not opted out" do
        context "and the user is flagged in individually" do
          before do
            rollout.flags.create(flag_subject: user)
          end

          it "returns true" do
            user.rollout?(:bar).should be_true
          end
        end

        context "and the user is flagged in as a percentage" do
          before do
            rollout.flags.create(percentage_type: "User", percentage: 100)
          end

          it "returns true" do
            user.rollout?(:bar).should be_true
          end
        end

        context "and the user is flagged in via a group" do
          before do
            ActiveRecord::Rollout.define_user_group "name_foo" do |user|
              user.name == "foo"
            end

            rollout.flags.create(group_type: "User", group_name: "name_foo")
          end

          it "returns true" do
            user.rollout?(:bar).should be_true
          end
        end
      end
    end
  end
end
