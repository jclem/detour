require "spec_helper"

describe "listing percentage flags for a type" do
  let(:feature)          { create :feature }
  let!(:percentage_flag) { create :percentage_flag, feature: feature }

  before do
    Detour.config.grep_dirs = %w[spec/dummy/app/**/*.{rb,erb}]
    visit "/detour/flags/users"
  end

  it "displays the percentage flag for the feature" do
    page.find("#features_#{feature.name}_users_percentage_flag_attributes_percentage").value.to_i.should eq percentage_flag.percentage
  end
end
