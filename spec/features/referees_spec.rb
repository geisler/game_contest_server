require 'spec_helper'

describe "RefereePages" do
  let (:creator) { FactoryGirl.create(:contest_creator) }

  subject { page }

  describe "create" do
    let (:submit) { 'Create Referee' }
    let (:name) { 'Test Referee' }
    let (:rules) { 'http://example.com/path/to/rules' }
    let (:num_players) { '2' }
    let (:file_location) { Rails.root.join('spec', 'files', 'referee.test') }

    before do
      login creator
      visit new_referee_path
    end

    describe "invalid information" do
      describe "missing information" do
	it "should not create a referee" do
	  expect { click_button submit }.not_to change(Referee, :count)
	end

	describe "after submission" do
	  before { click_button submit }

	  it { should have_alert(:danger) }
	end
      end

      describe "words for number of players" do
	before do
	  fill_in 'Name', with: name
	  fill_in 'Rules', with: rules
	  fill_in 'Players', with: 'two'
	  attach_file('Upload file', file_location)

	  click_button submit
	end

	it { should have_alert(:danger) }
      end
    end

    describe "valid information" do
      before do
	fill_in 'Name', with: name
	fill_in 'Rules', with: rules
	fill_in 'Players', with: num_players
	attach_file('Upload file', file_location)
      end

      it "should create a referee" do
	expect { click_button submit }.to change(Referee, :count).by(1)
      end

      describe "after submission" do
	before { click_button submit }

	specify { expect(Referee.find_by(name: name).user).to eq(creator) }

	it { should have_alert(:success, text: 'Referee created') }
	it { should have_content(name) }
	it { should have_link('Rules', href: rules) }
	it { should have_content(num_players) }
      end
    end
  end
end
