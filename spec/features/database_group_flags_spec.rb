require "spec_helper"

describe "creating database group flags" do
  let!(:feature) { create :feature }
  let!(:group) { create :group, flaggable_type: "User" }
  let(:checkbox) { "features[#{feature.name}][users_database_group_flags_attributes[#{group.name}]][to_keep]" }

  before do
    visit "/detour/flags/users"
    check checkbox
  end

  it "creates the database group flag" do
    click_button "Save Changes"
    feature.reload.users_database_group_flags.map(&:group).should eq [group]
  end

  context "when there are errors in other fields" do
    it "preserves the database group flag option" do
      fill_in "features[#{feature.name}][users_percentage_flag_attributes][percentage]", with: 101
      click_button "Save Changes"
      page.find("input[type='checkbox'][name='#{checkbox}']").should be_checked
    end
  end
end

describe "removing database group flags" do
  let!(:feature) { create :feature }
  let(:group) { create :group, flaggable_type: "User" }
  let!(:group_flag) { create :database_group_flag, feature: feature, group: group, flaggable_type: "User" }
  let(:checkbox) { "features[#{feature.name}][users_database_group_flags_attributes[#{group.name}]][to_keep]" }

  before do
    visit "/detour/flags/users"
    uncheck checkbox
  end

  it "removes the database group flag" do
    click_button "Save Changes"
    feature.reload.users_database_group_flags.should be_empty
  end

  context "when there are errors in other fields" do
    it "preserves the database group flag option" do
      fill_in "features[#{feature.name}][users_percentage_flag_attributes][percentage]", with: 101
      click_button "Save Changes"
      page.find("input[type='checkbox'][name='#{checkbox}']").should_not be_checked
    end
  end
end
