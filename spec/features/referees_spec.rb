require 'spec_helper'

describe "RefereePages" do
  let (:creator) { FactoryGirl.create(:contest_creator) }
  let (:name) { 'Test Referee' }
  let (:rules) { 'http://example.com/path/to/rules' }
  let (:num_players) { '2' }
  let (:file_location) { Rails.root.join('spec', 'files', 'referee.test') }
  let (:server_location) { Rails.root.join('code', 'referees', 'test').to_s }

  subject { page }

  describe "create" do
    let (:submit) { 'Create Referee' }

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
    end

    describe "valid information" do
      before do
	fill_in 'Name', with: name
	fill_in 'Rules', with: rules
	select num_players, from: 'Players'
	attach_file('Upload file', file_location)
      end

      it "should create a referee" do
	expect { click_button submit }.to change(Referee, :count).by(1)
      end

      it "should add the code to the right directory" do
	expect do
	  click_button submit
	end.to change{ Dir.entries(server_location).size }.by(1)
      end

      describe "redirects properly", type: :request do
	before do
	  login creator, avoid_capybara: true
	  post referees_path, referee: { name: name,
					 rules_url: rules,
					 players_per_game: num_players,
					 upload: fixture_file_upload(file_location) }
	end

	specify { expect(response).to redirect_to(referee_path(assigns(:referee))) }
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

  describe "edit" do
    let (:referee) { FactoryGirl.create(:referee, user: creator) }
    let!(:orig_name) { referee.name }
    let (:submit) { 'Update Referee' }

    before do
      login creator
      visit edit_referee_path(referee)
    end

    it { should have_field('Name', with: referee.name) }
    it { should have_field('Rules', with: referee.rules_url) }
    it { should have_select('Players', selected: referee.players_per_game.to_s) }

    describe "with invalid information" do
      before do
	fill_in 'Name', with: ''
	fill_in 'Rules', with: "#{rules}/updated"
	select num_players, from: 'Players'
	attach_file('Upload file', file_location)
      end

      describe "does not change data" do
	before { click_button submit }

	specify { expect(referee.reload.name).not_to eq('') }
	specify { expect(referee.reload.name).to eq(orig_name) }
      end

      it "does not add a new referee to the system" do
	expect { click_button submit }.not_to change(Referee, :count)
      end

      it "produces an error message" do
	click_button submit
	should have_alert(:danger)
      end
    end

    describe "with forbidden attributes", type: :request do
      before do
	login creator, avoid_capybara: true
	patch referee_path(referee), referee: { file_location: '/path/to/file' }
      end

      specify { expect(referee.reload.file_location).not_to eq('/path/to/file') }
    end

    describe "with valid information" do
      before do
	fill_in 'Name', with: name
	fill_in 'Rules', with: "#{rules}/updated"
	select num_players, from: 'Players'
	attach_file('Upload file', file_location)
      end

      describe "changes the data" do
	before { click_button submit }

	specify { expect(referee.reload.name).to eq(name) }
	specify { expect(referee.reload.rules_url).to eq("#{rules}/updated") }
	specify { expect(referee.reload.players_per_game).to eq(num_players.to_i) }
      end

      describe "redirects properly", type: :request do
	before do
	  login creator, avoid_capybara: true
	  patch referee_path(referee), referee: { name: name,
						  rules_url: "#{rules}/updated",
						  players_per_game: num_players,
						  upload: fixture_file_upload(file_location) }
	end

	specify { expect(response).to redirect_to(referee_path(referee)) }
      end

      it "produces an update message" do
	click_button submit
	should have_alert(:success)
      end

      it "does not add a new user to the system" do
	expect { click_button submit }.not_to change(Referee, :count)
      end
    end

    it "should modify an existing referee" do
      expect do
	click_button submit
      end.not_to change{ Dir.entries(server_location).size }
    end
  end

  describe "destroy", type: :request do
    let!(:referee) { FactoryGirl.create(:referee, user: creator) }

    before do
      login creator, avoid_capybara: true
    end

    it "should remove the referee from the file system" do
      expect do
	delete referee_path(referee)
      end.to change{ Dir.entries(server_location).size }.by(-1)
    end

    describe "redirects properly" do
      before { delete referee_path(referee) }

      specify { expect(response).to redirect_to(referees_path) }
    end

    it "produces a delete message" do
      delete referee_path(referee)
      get response.location
      response.body.should have_alert(:success)
    end

    it "removes a referee from the system" do
      expect { delete referee_path(referee) }.to change(Referee, :count).by(-1)
    end
  end

  describe "show" do
    let (:referee) { FactoryGirl.create(:referee) }

    before do
      5.times { FactoryGirl.create(:contest, referee: referee) }

      visit referee_path(referee)
    end

    it { should have_content(referee.name) }
    it { should have_link('Rules', href: referee.rules_url) }
    it { should have_content(referee.players_per_game.to_s) }
    it { should_not have_content(referee.file_location) }
    it { should have_content(referee.user.username) }
    it "lists all the contests that use this referee" do
      Contest.all.each do |contest|
	should have_selector('li', text: contest.name)
	should have_link(contest.name, href: contest_path(contest))
      end
    end
  end

  describe "show all" do
    before do
      5.times { FactoryGirl.create(:referee) }

      visit referees_path
    end

    it "lists all the referees in the system" do
      Referee.all.each do |ref|
	should have_selector('li', text: ref.name)
	should have_link(ref.name, href: referee_path(ref))
      end
    end
  end
end
