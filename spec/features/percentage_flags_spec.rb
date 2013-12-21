require "spec_helper"

describe "listing percentage flags for a type" do
  let(:feature)          { create :feature }
  let!(:percentage_flag) { create :percentage_flag, feature: feature }

  before do
    visit "/detour/flags/users"
  end

  it "displays the percentage flag for the feature" do
    page.find("#features_#{feature.name}_users_percentage_flag_attributes_percentage").value.to_i.should eq percentage_flag.percentage
  end
end

describe "creating a percentage flag" do
  let!(:feature) { create :feature }

  before do
    visit "/detour/flags/users"
  end

  context "when successful" do
    before do
      fill_in "features[#{feature.name}][users_percentage_flag_attributes][percentage]", with: "50"
      click_button "Save Changes"
    end

    it "saves the new feature" do
      feature.users_percentage_flag.percentage.should eq 50
    end

    it "displays a success message" do
      page.should have_content "Your flags have been successfully updated."
    end
  end

  context "when unsuccessful" do
    before do
      fill_in "features[#{feature.name}][users_percentage_flag_attributes][percentage]", with: "foo"
      click_button "Save Changes"
    end

    it "displays error messages" do
      page.should have_content "#{feature.name}: Users percentage flag percentage is not a number"
    end
  end
end

describe "destroying a percentage flag" do
  let(:feature)          { create :feature }
  let!(:percentage_flag) { create :percentage_flag, feature: feature }

  before do
    visit "/detour/flags/users"
    fill_in "features[#{feature.name}][users_percentage_flag_attributes][percentage]", with: ""
    click_button "Save Changes"
  end

  it "destroys the percentage flag" do
    feature.users_percentage_flag.should be_nil
  end
end
