require "spec_helper"

describe "the home page" do
  before do
    visit "/detour"
  end

  it "displays the name of the gem" do
    page.should have_content "Detour"
  end
end
