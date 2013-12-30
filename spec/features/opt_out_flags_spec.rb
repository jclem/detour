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

describe "creating opt-outs", js: true do
  let(:user) { create :user }
  let!(:feature) { create :feature }

  before do
    User.instance_variable_set "@detour_flaggable_find_by", :email
    visit "/detour/opt-outs/#{feature.name}/users"
    page.find("[data-target='#create-flaggable-flag']").click
  end

  context "when creating multiple opt-outs" do
    let(:user2) { create :user, email: "another_user@example.com" }

    context "when successful" do
      before do
        fill_in "ids", with: [user.email, user2.email].join(",")
        click_button "Create Opt-out"
      end

      it "displays a success message" do
        page.should have_content "Users #{user.email}, #{user2.email} have been opted out of #{feature.name}"
      end
    end

    context "when unsuccessful" do
      before do
        fill_in "ids", with: "#{user.email},foo"
        click_button "Create Opt-out"
      end

      it "displays error messages" do
        page.should have_content "Couldn't find User with email = foo"
      end
    end
  end

  context "when creating single opt-outs" do
    context "when successful" do
      before do
        fill_in "ids", with: user.email
        click_button "Create Opt-out"
      end

      it "displays a success message" do
        page.should have_content "User #{user.email} has been opted out of #{feature.name}"
      end

      it "renders the new opt-out" do
        within "table" do
          page.should have_content user.email
        end
      end
    end

    context "when unsuccessful" do
      before do
        fill_in "ids", with: "foo"
        click_button "Create Opt-out"
      end

      it "displays error messages" do
        page.should have_content "Couldn't find User with email = foo"
      end
    end
  end
end

describe "destroying opt-outs", js: true do
  let!(:flag) { create :opt_out_flag }

  before do
    visit "/detour/opt-outs/#{flag.feature.name}/users"
    page.find(".delete-flag").click
    click_link "Delete Opt-out"
  end

  it "displays a flash message" do
    page.should have_content "#{flag.feature.name} opt-out for User #{flag.flaggable.send flag.flaggable_type.constantize.detour_flaggable_find_by} has been deleted."
  end

  it "destroys the opt-out" do
    expect { flag.reload }.to raise_error ActiveRecord::RecordNotFound
  end


  it "removes the flag from the list" do
    page.should_not have_content flag.flaggable.email
  end
end
