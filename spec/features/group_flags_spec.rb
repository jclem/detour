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
