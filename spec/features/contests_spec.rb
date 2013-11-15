require 'spec_helper'

include ActionView::Helpers::DateHelper

describe "ContestsPages" do
  let (:creator) { FactoryGirl.create(:contest_creator) }
  let!(:referee) { FactoryGirl.create(:referee) }
  # give slack for time to run all the tests in this file
  let (:now) { Time.current + 1.minute }
  let (:name) { 'Test Contest' }
  let (:description) { 'Contest description' }
  let (:type) { 'Testing' }

  subject { page }

  describe "create" do
    let (:submit) { 'Create Contest' }

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

      illegal_dates = [{month: 'February', day: '30'},
		       {month: 'February', day: '31'},
		       {year: '2014', month: 'February', day: '29'},
		       {month: 'April', day: '31'},
		       {month: 'June', day: '31'},
		       {month: 'September', day: '31'},
		       {month: 'November', day: '31'}]
      illegal_dates.each do |date|
	describe "illegal date (#{date.to_s})" do
	  before do
	    select_illegal_datetime('Deadline', date)
	    select_datetime(now, 'Start')
	    fill_in 'Description', with: description
	    fill_in 'Name', with: name
	    fill_in 'Contest Type', with: type
	    select referee.name, from: 'Referee'
	    click_button submit
	  end

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
	fill_in 'Contest Type', with: type
	select referee.name, from: 'Referee'
      end

      it "should create a contest" do
	expect { click_button submit }.to change(Contest, :count).by(1)
      end

      describe "redirects properly", type: :request do
	before do
	  login creator, avoid_capybara: true
	  post contests_path, contest: { deadline: now.strftime("%F %T"),
					 start: now.strftime("%F %T"),
					 description: description,
					 name: name,
					 contest_type: type,
					 referee_id: referee.id }
	end

	specify { expect(response).to redirect_to(contest_path(assigns(:contest))) }
      end

      describe "after submission" do
	let (:contest) { Contest.find_by(name: name) }

	before { click_button submit }

	specify { expect(contest.user).to eq(creator) }

	it { should have_alert(:success, text: 'Contest created') }
	it { should have_content(/less than a minute|1 minute/) }
	it { should have_content(description) }
	it { should have_content(name) }
	it { should have_content(type) }
	it { should have_content(contest.referee.name) }
      end
    end
  end

  describe "edit" do
    let (:contest) { FactoryGirl.create(:contest, user: creator) }
    let!(:orig_name) { contest.name }
    let (:submit) { 'Update Contest' }

    before do
      login creator
      visit edit_contest_path(contest)
    end

    it { expect_datetime_select(contest.deadline, 'Deadline') }
    it { expect_datetime_select(contest.start, 'Start') }
    it { should have_field('Description', with: contest.description) }
    it { should have_field('Name', with: contest.name) }
    it { should have_field('Contest Type', with: contest.contest_type) }
    it { should have_select('Referee', selected: contest.referee.name) }

    describe "with invalid information" do
      before do
	select_datetime(now, 'Deadline')
	select_datetime(now, 'Start')
	fill_in 'Name', with: ''
	fill_in 'Description', with: description
	fill_in 'Contest Type', with: type
	select referee.name, from: 'Referee'
      end

      describe "does not change data" do
	before { click_button submit }

	specify { expect(contest.reload.name).not_to eq('') }
	specify { expect(contest.reload.name).to eq(orig_name) }
      end

      it "does not add a new contest to the system" do
	expect { click_button submit }.not_to change(Contest, :count)
      end

      it "produces an error message" do
	click_button submit
	should have_alert(:danger)
      end
    end

    describe "with valid information" do
      before do
	select_datetime(now, 'Deadline')
	select_datetime(now, 'Start')
	fill_in 'Name', with: name
	fill_in 'Description', with: description
	fill_in 'Contest Type', with: type
	select referee.name, from: 'Referee'
      end

      describe "changes the data" do
	before { click_button submit }

	it { should have_alert(:success) }
	specify { expect_same_minute(contest.reload.deadline, now) }
	specify { expect_same_minute(contest.reload.start, now) }
	specify { expect(contest.reload.name).to eq(name) }
	specify { expect(contest.reload.description).to eq(description) }
	specify { expect(contest.reload.contest_type).to eq(type) }
	specify { expect(contest.reload.referee.name).to eq(referee.name) }
      end

      describe "redirects properly", type: :request do
	before do
	  login creator, avoid_capybara: true
	  patch contest_path(contest), contest: { deadline: now.strftime("%F %T"),
						  start: now.strftime("%F %T"),
						  description: description,
						  name: name,
						  contest_type: type,
						  referee_id: referee.id }
	end

	specify { expect(response).to redirect_to(contest_path(contest)) }
      end

      it "does not add a new contest to the system" do
	expect { click_button submit }.not_to change(Contest, :count)
      end
    end
  end

  describe "destroy", type: :request do
    let!(:contest) { FactoryGirl.create(:contest, user: creator) }

    before do
      login creator, avoid_capybara: true
    end

    describe "redirects properly" do
      before { delete contest_path(contest) }

      specify { expect(response).to redirect_to(contests_path) }
    end

    it "produces a delete message" do
      delete contest_path(contest)
      get response.location
      response.body.should have_alert(:success)
    end

    it "removes a contest from the system" do
      expect { delete contest_path(contest) }.to change(Contest, :count).by(-1)
    end
  end

  describe "show" do
    let (:contest) { FactoryGirl.create(:contest) }

    before { visit contest_path(contest) }

    it { should have_content(contest.name) }
    it { should have_content(contest.description) }
    it { should have_content(distance_of_time_in_words_to_now(contest.deadline)) }
    it { should have_content(distance_of_time_in_words_to_now(contest.start)) }
    it { should have_content(contest.contest_type) }
    it { should have_content(contest.user.username) }
    it { should have_link(contest.user.username, user_path(contest.user)) }
    it { should have_content(contest.referee.name) }
    it { should have_link(contest.referee.name, referee_path(contest.referee)) }
    # add Players that use this contest
  end

  describe "show all" do
    before do
      5.times { FactoryGirl.create(:contest) }

      visit contests_path
    end

    it "lists all the contests in the system" do
      Contest.all.each do |c|
	should have_selector('li', text: c.name)
	should have_link(c.name, contest_path(c))
      end
    end
  end
end
