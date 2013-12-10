require "spec_helper"

describe "rollout:create" do
  include_context "rake"

  it "creates the given feature" do
    ActiveRecord::Rollout::Feature.should_receive(:find_or_create_by_name!).with("foo")
    subject.invoke("foo")
  end
end

describe "rollout:destroy" do
  include_context "rake"

  let(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "destroys the given feature" do
    ActiveRecord::Rollout::Feature.should_receive(:find_by_name!).with(feature.name).and_return(feature)
    feature.should_receive(:destroy)
    subject.invoke("foo")
  end
end

describe "rollout:activate" do
  include_context "rake"

  let(:user) { User.create(name: "foo") }
  let!(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "activates the feature for the record" do
    ActiveRecord::Rollout::Feature.should_receive(:add_record_to_feature).with(user, "foo")
    subject.invoke("foo", "User", user.id.to_s)
  end

  it "does not require a class if defined_flaggable_class is set" do
    ActiveRecord::Rollout::Feature.should_receive(:add_record_to_feature).with(user, "foo")
    ActiveRecord::Rollout::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke("foo", user.id.to_s) }.to_not raise_error
  end
end

describe "rollout:deactivate" do
  include_context "rake"

  let(:user) { User.create(name: "foo") }
  let!(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "deactivates the feature for the record" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_record_from_feature).with(user, "foo")
    subject.invoke("foo", "User", user.id.to_s)
  end

  it "does not require a class if defined_flaggable_class is set" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_record_from_feature).with(user, "foo")
    ActiveRecord::Rollout::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke("foo", user.id.to_s) }.to_not raise_error
  end
end

describe "rollout:opt_out" do
  include_context "rake"

  let(:user) { User.create(name: "foo") }
  let!(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "deactivates the feature for the record" do
    ActiveRecord::Rollout::Feature.should_receive(:opt_record_out_of_feature).with(user, "foo")
    subject.invoke("foo", "User", user.id.to_s)
  end

  it "does not require a class if defined_flaggable_class is set" do
    ActiveRecord::Rollout::Feature.should_receive(:opt_record_out_of_feature).with(user, "foo")
    ActiveRecord::Rollout::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke("foo", user.id.to_s) }.to_not raise_error
  end
end

describe "rollout:un_opt_out" do
  include_context "rake"

  let(:user) { User.create(name: "foo") }
  let!(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "deactivates the feature for the record" do
    ActiveRecord::Rollout::Feature.should_receive(:un_opt_record_out_of_feature).with(user, "foo")
    subject.invoke("foo", "User", user.id.to_s)
  end

  it "does not require a class if defined_flaggable_class is set" do
    ActiveRecord::Rollout::Feature.should_receive(:un_opt_record_out_of_feature).with(user, "foo")
    ActiveRecord::Rollout::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke("foo", user.id.to_s) }.to_not raise_error
  end
end

describe "rollout:activate_group" do
  include_context "rake"

  let!(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "activates the feature for the group" do
    ActiveRecord::Rollout::Feature.should_receive(:add_group_to_feature).with("User", "admins", "foo")
    subject.invoke("foo", "User", "admins")
  end

  it "does not require a class if defined_flaggable_class is set" do
    ActiveRecord::Rollout::Feature.should_receive(:add_group_to_feature).with("User", "admins", "foo")
    ActiveRecord::Rollout::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke("foo", "admins") }.to_not raise_error
  end
end

describe "rollout:deactivate_group" do
  include_context "rake"

  let!(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "deactivates the feature for the group" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_group_from_feature).with("User", "admins", "foo")
    subject.invoke("foo", "User", "admins")
  end

  it "does not require a class if defined_flaggable_class is set" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_group_from_feature).with("User", "admins", "foo")
    ActiveRecord::Rollout::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke("foo", "admins") }.to_not raise_error
  end
end

describe "rollout:activate_percentage" do
  include_context "rake"

  let!(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "activates the feature for the percentage" do
    ActiveRecord::Rollout::Feature.should_receive(:add_percentage_to_feature).with("User", 50, "foo")
    subject.invoke("foo", "User", "50")
  end

  it "does not require a class if defined_flaggable_class is set" do
    ActiveRecord::Rollout::Feature.should_receive(:add_percentage_to_feature).with("User", 50, "foo")
    ActiveRecord::Rollout::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke("foo", "50") }.to_not raise_error
  end
end

describe "rollout:deactivate_percentage" do
  include_context "rake"

  let!(:feature) { ActiveRecord::Rollout::Feature.create(name: "foo") }

  it "deactivates the feature for the percentage" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_percentage_from_feature).with("User", "foo")
    subject.invoke("foo", "User")
  end

  it "does not require a class if defined_flaggable_class is set" do
    ActiveRecord::Rollout::Feature.should_receive(:remove_percentage_from_feature).with("User", "foo")
    ActiveRecord::Rollout::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke("foo") }.to_not raise_error
  end
end
