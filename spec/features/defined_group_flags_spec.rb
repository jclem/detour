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
  let(:checkbox) { "features[#{feature.name}][users_defined_group_flags_attributes[admins]][to_keep]" }

  before do
    Detour.config.define_user_group :admins do |user|
    end

    visit "/detour/flags/users"
    check checkbox
  end

  it "creates the group flag" do
    click_button "Save Changes"
    feature.reload.users_defined_group_flags.first.group_name.should eq "admins"
  end

  context "when there are errors in other fields" do
    it "preserves the database group flag option" do
      fill_in "features[#{feature.name}][users_percentage_flag_attributes][percentage]", with: 101
      click_button "Save Changes"
      page.find("input[type='checkbox'][name='#{checkbox}']").should be_checked
    end
  end
end

describe "removing defined group flags" do
  let(:feature)     { create :feature }
  let!(:group_flag) { create :defined_group_flag, feature: feature, group_name: "admins" }
  let(:checkbox) { "features[#{feature.name}][users_defined_group_flags_attributes[admins]][to_keep]" }

  before do
    Detour.config.define_user_group :admins do |user|
    end

    visit "/detour/flags/users"
    uncheck checkbox
  end

  it "creates the group flag" do
    click_button "Save Changes"
    feature.reload.users_defined_group_flags.should be_empty
  end

  context "when there are errors in other fields" do
    it "preserves the database group flag option" do
      fill_in "features[#{feature.name}][users_percentage_flag_attributes][percentage]", with: 101
      click_button "Save Changes"
      page.find("input[type='checkbox'][name='#{checkbox}']").should_not be_checked
    end
  end
end
