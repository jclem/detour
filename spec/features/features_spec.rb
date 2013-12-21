require "spec_helper"

describe "listing features for a type" do
  let!(:feature) { create :feature }

  before do
    Detour.config.grep_dirs = %w[spec/dummy/app/**/*.{rb,erb}]
    visit "/detour/flags/users"
  end

  it "lists every persisted feature" do
    page.should have_content feature.name
  end

  it "lists features found in the codebase" do
    page.should have_content "show_widget_table"
  end
end
