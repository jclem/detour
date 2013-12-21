require "spec_helper"

describe "counting flaggable flags" do
  let!(:flag) { create :flag_in_flag }

  before do
    visit "/detour/flags/users"
  end

  it "displays the defined groups" do
    within "tr#feature_#{flag.feature.id} td.flag-in-count" do
      page.should have_content 1
    end
  end
end
