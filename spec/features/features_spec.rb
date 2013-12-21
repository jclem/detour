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

describe "creating a new feature", js: true do
  before do
    visit "/detour/flags/users"
    click_link "Create a Feature"
  end

  context "when successful" do
    before do
      fill_in "feature[name]", with: "foo"
      click_button "Create Feature"
    end

    it "displays a flash message" do
      page.should have_content "Your feature has been successfully created."
    end

    it "lists the new feature" do
      Detour::Feature.find_by_name("foo").should_not be_nil
    end
  end

  context "when unsuccessful" do
    before do
      click_button "Create Feature"
    end

    it "displays error messages" do
      page.should have_content "Name can't be blank"
    end
  end
end
