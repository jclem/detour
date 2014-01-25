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
  it "lists every member", pending: true
end

describe "creating a group" do
  it "shows the newly created group", pending: true
end

describe "updating a group" do
  it "shows the new group attributes", pending: true
end

describe "adding a member to a group" do
  it "shows the new group member", pending: true
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
