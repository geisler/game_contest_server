require 'spec_helper'

describe "ContestsPages" do
  let (:creator) { FactoryGirl.create(:contest_creator) }
  let!(:referee) { FactoryGirl.create(:referee) }

  subject { page }

  describe "create" do
    let (:submit) { 'Create Contest' }
    let (:now) { Time.now.utc }
    let (:name) { 'Test Contest' }
    let (:description) { 'Contest description' }
    let (:type) { 'Testing' }

    before do
      login creator
      visit new_contest_path
    end

    describe "invalid information" do
      describe "missing information" do
	it "should not create a contest" do
	  expect { click_button submit }.not_to change(Contest, :count)
	end

	describe "after submission" do
	  before { click_button submit }

	  it { should have_alert(:danger) }
	end
      end
    end

    describe "valid information" do
      before do
	select_datetime(now, 'Deadline')
	select_datetime(now, 'Start')
	fill_in 'Description', with: description
	fill_in 'Name', with: name
	fill_in 'Contest type', with: type
	select referee.name, from: 'Referee'
      end

      it "should create a contest" do
	expect { click_button submit }.to change(Contest, :count).by(1)
      end

      describe "after submission" do
	before { click_button submit }

	specify { expect(Contest.find_by(name: name).user).to eq(creator) }

	it { should have_alert(:success, text: 'Contest created') }
	it { should have_content(/less than a minute|1 minute/) }
	it { should have_content(description) }
	it { should have_content(name) }
	it { should have_content(type) }
      end
    end
  end
end
