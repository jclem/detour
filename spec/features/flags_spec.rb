require "spec_helper"

describe "listing flags for a type" do
  let!(:feature) { create :feature }

  before do
    visit "/detour/flags/user"
  end

  it "lists every persisted feature" do
    page.should have_content feature.name
  end
end
