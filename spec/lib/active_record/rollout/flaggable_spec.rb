require "spec_helper"

describe ActiveRecord::Rollout::Flaggable do
  subject { User.new }

  it { should have_many :flaggable_flags }
  it { should have_many :opt_out_flags }
  it { should have_many(:features).through(:flaggable_flags) }

  describe "#feature?" do
    let(:user) { User.create(name: "foo") }
    let(:feature) { ActiveRecord::Rollout::Feature.create(name: "bar") }

    context "when given a block" do
      context "and the user is flagged in" do
        before do
          feature.flaggable_flags.create(flaggable: user)
        end

        it "calls the block" do
          foo = "foo"
          user.feature?(:bar) { foo = "bar" }
          foo.should eq "bar"
        end

        context "when the block raises an exception" do
          it "increments the failure_count of the feature" do
            begin
              user.feature? :bar do
                raise "This is an exception"
              end
            rescue
              feature.reload.failure_count.should eq 1
            end
          end

          it "raises the exception" do
            expect do
              user.feature? :bar do
                raise "This is an exception"
              end
            end.to raise_error "This is an exception"
          end
        end
      end

      context "and the user is not flagged in" do
        it "does not call the block" do
          foo = "foo"
          user.feature?(:bar) { foo = "bar" }
          foo.should eq "foo"
        end
      end
    end

    context "when the user is not flagged in" do
      it "returns false" do
        user.feature?(:bar).should be_false
      end
    end

    context "when the user is flagged in" do
      context "and the user is opted out" do
        before do
          feature.flaggable_flags.create(flaggable: user)
          user.opt_out_flags.create(feature: feature)
        end

        it "returns false" do
          user.feature?(:bar).should be_false
        end
      end

      context "and the user is not opted out" do
        context "and the user is flagged in individually" do
          before do
            feature.flaggable_flags.create(flaggable: user)
          end

          it "returns true" do
            user.feature?(:bar).should be_true
          end
        end

        context "and the user is flagged in as a percentage" do
          before do
            feature.percentage_flags.create(flaggable_type: "User", percentage: 100)
          end

          it "returns true" do
            user.feature?(:bar).should be_true
          end
        end

        context "and the user is flagged in via a group" do
          before do
            ActiveRecord::Rollout::Feature.define_user_group "name_foo" do |user|
              user.name == "foo"
            end

            feature.group_flags.create(flaggable_type: "User", group_name: "name_foo")
          end

          it "returns true" do
            user.feature?(:bar).should be_true
          end
        end
      end
    end
  end
end
