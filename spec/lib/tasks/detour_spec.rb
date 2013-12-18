require "spec_helper"

describe "detour:create" do
  include_context "rake"

  it "creates the given feature" do
    Detour::Feature.should_receive(:find_or_create_by_name!).with("foo")
    subject.invoke("foo")
  end
end

describe "detour:destroy" do
  include_context "rake"

  let(:feature) { create :feature }

  it "destroys the given feature" do
    Detour::Feature.should_receive(:find_by_name!).with(feature.name).and_return(feature)
    feature.should_receive(:destroy)
    subject.invoke(feature.name)
  end
end

describe "detour:activate" do
  include_context "rake"

  let(:user)    { create :user }
  let(:feature) { create :feature }

  it "activates the feature for the record" do
    Detour::Feature.should_receive(:add_record_to_feature).with(user, feature.name)
    subject.invoke(feature.name, user.class.to_s, user.id.to_s)
  end

  it "does not require a class if defined_flaggable_class is set" do
    Detour::Feature.should_receive(:add_record_to_feature).with(user, feature.name)
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", user.class.to_s
    expect { subject.invoke(feature.name, user.id.to_s) }.to_not raise_error
  end
end

describe "detour:deactivate" do
  include_context "rake"

  let(:user)    { create :user }
  let(:feature) { create :feature }

  it "deactivates the feature for the record" do
    Detour::Feature.should_receive(:remove_record_from_feature).with(user, feature.name)
    subject.invoke(feature.name, user.class.to_s, user.id.to_s)
  end

  it "does not require a class if defined_flaggable_class is set" do
    Detour::Feature.should_receive(:remove_record_from_feature).with(user, feature.name)
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", user.class.to_s
    expect { subject.invoke(feature.name, user.id.to_s) }.to_not raise_error
  end
end

describe "detour:opt_out" do
  include_context "rake"

  let(:user)    { create :user }
  let(:feature) { create :feature }

  it "deactivates the feature for the record" do
    Detour::Feature.should_receive(:opt_record_out_of_feature).with(user, feature.name)
    subject.invoke(feature.name, user.class.to_s, user.id.to_s)
  end

  it "does not require a class if defined_flaggable_class is set" do
    Detour::Feature.should_receive(:opt_record_out_of_feature).with(user, feature.name)
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", user.class.to_s
    expect { subject.invoke(feature.name, user.id.to_s) }.to_not raise_error
  end
end

describe "detour:un_opt_out" do
  include_context "rake"

  let(:user)    { create :user }
  let(:feature) { create :feature }

  it "deactivates the feature for the record" do
    Detour::Feature.should_receive(:un_opt_record_out_of_feature).with(user, feature.name)
    subject.invoke(feature.name, user.class.to_s, user.id.to_s)
  end

  it "does not require a class if defined_flaggable_class is set" do
    Detour::Feature.should_receive(:un_opt_record_out_of_feature).with(user, feature.name)
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", user.class.to_s
    expect { subject.invoke(feature.name, user.id.to_s) }.to_not raise_error
  end
end

describe "detour:activate_group" do
  include_context "rake"

  let(:feature) { create :feature }

  it "activates the feature for the group" do
    Detour::Feature.should_receive(:add_group_to_feature).with("User", "admins", feature.name)
    subject.invoke(feature.name, "User", "admins")
  end

  it "does not require a class if defined_flaggable_class is set" do
    Detour::Feature.should_receive(:add_group_to_feature).with("User", "admins", feature.name)
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke(feature.name, "admins") }.to_not raise_error
  end
end

describe "detour:deactivate_group" do
  include_context "rake"

  let(:feature) { create :feature }

  it "deactivates the feature for the group" do
    Detour::Feature.should_receive(:remove_group_from_feature).with("User", "admins", feature.name)
    subject.invoke(feature.name, "User", "admins")
  end

  it "does not require a class if defined_flaggable_class is set" do
    Detour::Feature.should_receive(:remove_group_from_feature).with("User", "admins", feature.name)
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke(feature.name, "admins") }.to_not raise_error
  end
end

describe "detour:activate_percentage" do
  include_context "rake"

  let(:feature) { create :feature }

  it "activates the feature for the percentage" do
    Detour::Feature.should_receive(:add_percentage_to_feature).with("User", 50, feature.name)
    subject.invoke(feature.name, "User", "50")
  end

  it "does not require a class if defined_flaggable_class is set" do
    Detour::Feature.should_receive(:add_percentage_to_feature).with("User", 50, feature.name)
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke(feature.name, "50") }.to_not raise_error
  end
end

describe "detour:deactivate_percentage" do
  include_context "rake"

  let(:feature) { create :feature }

  it "deactivates the feature for the percentage" do
    Detour::Feature.should_receive(:remove_percentage_from_feature).with("User", feature.name)
    subject.invoke(feature.name, "User")
  end

  it "does not require a class if defined_flaggable_class is set" do
    Detour::Feature.should_receive(:remove_percentage_from_feature).with("User", feature.name)
    Detour::Feature.instance_variable_set "@default_flaggable_class_name", "User"
    expect { subject.invoke(feature.name) }.to_not raise_error
  end
end
