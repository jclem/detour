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

describe "listing flag_in_flags" do
  let!(:flag) { create :flag_in_flag }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/flag-ins/#{flag.feature.name}/users"
  end

  it "displays the flagged-in model's find-by" do
    page.should have_content flag.flaggable.email
  end
end

describe "destroying flag_in_flags", js: true do
  let!(:flag) { create :flag_in_flag }

  before do
    visit "/detour/flag-ins/#{flag.feature.name}/users"
    page.find(".delete-flag").click
    click_link "Delete Flag-in"
  end

  it "displays a flash message" do
    page.should have_content "#{flag.feature.name} flag-in for User #{flag.flaggable.send flag.flaggable_type.constantize.detour_flaggable_find_by} has been deleted."
  end

  it "destroys the flag-in" do
    expect { flag.reload }.to raise_error ActiveRecord::RecordNotFound
  end


  it "removes the flag from the list" do
    page.should_not have_content flag.flaggable.email
  end
end
