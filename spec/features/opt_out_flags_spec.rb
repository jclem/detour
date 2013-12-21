require "spec_helper"

describe "counting opt out flags" do
  let!(:flag) { create :opt_out_flag }

  before do
    visit "/detour/flags/users"
  end

  it "displays the defined groups" do
    within "tr#feature_#{flag.feature.id} td.opt-out-count" do
      page.should have_content 1
    end
  end
end

