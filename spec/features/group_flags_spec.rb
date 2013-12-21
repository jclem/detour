require "spec_helper"

describe "listing defined groups" do
  before do
    Detour.config.define_user_group :admins do |user|
    end

    visit "/detour/flags/users"
  end

  it "displays the defined groups" do
    page.should have_content "admins"
  end
end

describe "creating defined group flags" do
  let!(:feature) { create :feature }

  before do
    Detour.config.define_user_group :admins do |user|
    end

    visit "/detour/flags/users"
    check "features[#{feature.name}][users_group_flags_attributes[admins]][to_keep]"
    click_button "Save Changes"
  end

  it "creates the group flag" do
    feature.reload.users_group_flags.first.group_name.should eq "admins"
  end
end

describe "removing defined group flags" do
  let(:feature)     { create :feature }
  let!(:group_flag) { create :group_flag, feature: feature, group_name: "admins" }

  before do
    Detour.config.define_user_group :admins do |user|
    end

    visit "/detour/flags/users"
    uncheck "features[#{feature.name}][users_group_flags_attributes[admins]][to_keep]"
    click_button "Save Changes"
  end

  it "creates the group flag" do
    feature.reload.users_group_flags.should be_empty
  end
end
