require "spec_helper"

describe "listing groups" do
  let!(:group) { create :group }

  before do
    visit "/detour/groups"
  end

  it "lists every group" do
    within "ul#groups li.group" do
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

  it "lists every membership type" do
    within "table#memberships tbody tr.membership" do
      page.should have_content "User"
    end
  end

  it "lists every membership id" do
    within "table#memberships tbody tr.membership" do
      page.should have_content user.email
    end
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
      click_button "Create Group"
    end

    it "displays a flash message" do
      page.should have_content "Your group has been successfully created."
    end

    it "shows the newly created group" do
      within "ul#groups li.group" do
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

describe "updating a group", js: true do
  let(:group) { create :group }

  before do
    visit "/detour/groups/#{group.to_param}"
    page.find("[data-target='#edit-group']").click
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
    page.find("[data-target='#add-members']").click
  end

  context "when successful" do
    before do
      fill_in "membership[member_id]", with: user.email
      select "User", from: "membership[member_type]"
      click_button "Add Members"
    end

    it "displays a flash message" do
      page.should have_content "A new member has been added to the group"
    end

    it "shows the newly added member" do
      within "table#memberships tr.membership" do
        page.should have_content user.email
      end
    end
  end

  context "when unsuccessful" do
    before do
      select "User", from: "membership[member_type]"
      click_button "Add Members"
    end

    it "displays error messages" do
      page.should have_content "Couldn't find User with email ="
    end
  end
end

describe "bulk adding members to a group" do
  it "shows the new group members", pending: true
end

describe "removing a member from a group" do
  it "shows the remaining group members", pending: true
end

describe "destroying a group" do
  it "shows the remaining groups", pending: true
end
