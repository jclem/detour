require "spec_helper"

describe "listing groups" do
  let!(:group) { create :group }

  before do
    visit "/detour/groups"
  end

  it "lists every group" do
    within "ul li.group" do
      page.should have_content group.name
    end
  end
end

describe "showing a group" do
  let(:user)       { create :user }
  let(:group)      { create :group }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    create :membership, group: group, member: user
    visit "/detour/groups/#{group.to_param}"
  end

  it "lists every membership" do
    page.find("input[name=member_identifier]").value.should eq user.email
  end
end

describe "creating a group", js: true do
  before do
    visit "/detour/groups"
    page.find("[data-target='#create-group']").click
  end

  context "when successful" do
    before do
      fill_in "group[name]", with: "New Group"
      select "User", from: "group[flaggable_type]"
      click_button "Create Group"
    end

    it "displays a flash message" do
      page.should have_content "Your group has been successfully created."
    end

    it "shows the newly created group" do
      within "ul li.group" do
        page.should have_content "New Group"
      end
    end
  end

  context "when unsuccessful" do
    before do
      click_button "Create Group"
    end

    it "displays error messages" do
      page.should have_content "Name can't be blank"
    end
  end
end

describe "updating a group" do
  let(:group) { create :group }

  before do
    visit "/detour/groups/#{group.to_param}"
  end

  context "when successful" do
    before do
      fill_in "group[name]", with: "New Group Name"
      click_button "Update Group"
    end

    it "displays a flash message" do
      page.should have_content "Your group has been successfully updated."
    end

    it "shows the newly updated group" do
      within "h1" do
        page.should have_content "New Group Name"
      end
    end
  end

  context "when unsuccessful" do
    before do
      fill_in "group[name]", with: ""
      click_button "Update Group"
    end

    it "displays error messages" do
      page.should have_content "Name can't be blank"
    end
  end
end

describe "adding a member to a group", js: true do
  let(:group) { create :group }
  let!(:user) { create :user }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/groups/#{group.to_param}"
    page.find(".add-fields").click
  end

  context "when successful" do
    before do
      name = page.find("##{page.all("label")[-2][:for]}")[:name]
      fill_in name, with: user.email
      click_button "Update Group"
    end

    it "displays a flash message" do
      page.should have_content "Your group has been successfully updated."
    end

    it "shows the newly added member" do
      page.find("input[type='text'][disabled]").value.should eq user.email
    end
  end

  context "when unsuccessful" do
    before do
      click_button "Update Group"
    end

    it "displays error messages" do
      page.should have_content "Memberships user \"\" could not be found"
    end
  end
end

describe "removing a member from a group" do
  let(:group) { create :group }
  let(:user) { create :user }
  let!(:membership) { create :membership, group: group, member: user }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/groups/#{group.to_param}"
    name = page.find("##{page.all("label").last[:for]}")[:name]
    check name
    click_button "Update Group"
  end

  it "does not show the removed member" do
    page.should_not have_selector "label[for='group_memberships_attributes_0_member_key']"
  end
end

describe "destroying a group", js: true do
  let!(:group) { create :group }

  before do
    visit "/detour/groups/#{group.to_param}"
    click_button "Delete Group"
    page.find(".modal a").click
  end

  it "shows a flash message" do
    page.should have_content "Group \"#{group.name}\" has been deleted"
  end

  it "shows the remaining groups" do
    page.should_not have_selector ".group"
  end
end
