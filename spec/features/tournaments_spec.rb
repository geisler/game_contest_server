require 'spec_helper'

describe 'TournamentsPages' do
  let (:creator) { FactoryGirl.create(:contest_creator) }
  let!(:referee) { FactoryGirl.create(:referee) }
  let (:contest) { FactoryGirl.create(:contest, user: creator) }

  let (:name) { 'Test Tournament' }
  # Status shouldn't be in the form
  # let (:status) { 'waiting' }
  let (:now) { Time.current }
  let (:tournament_type) { 'Round Robin' }

  subject { page }

  describe 'create' do
    let(:submit) {'Create Tournament'}

    before do
      login creator
      visit new_contest_tournament_path(contest)
    end

    describe 'invalid information' do
      describe 'missing information' do
        it 'should not create a tournament' do
          expect { click_button submit }.not_to change(Tournament, :count)
        end

        describe "after submission" do
          before { click_button submit }

          it { should have_alert(:danger) }
        end
      end # missing info

      illegal_dates = [{month: 'Feb', day: '30'},
        {month: 'Feb', day: '31'},
        {year: '2015', month: 'Feb', day: '29'},
        {month: 'Apr', day: '31'},
        {month: 'Jun', day: '31'},
        {month: 'Sep', day: '31'},
        {month: 'Nov', day: '31'}]
      illegal_dates.each do |date|
        describe "illegal date (#{date.to_s})" do
          before do
            fill_in 'Name', with: name
            select_illegal_datetime('Start', date)
            select tournament_type, from: 'Tournament type'
            click_button submit
          end

          it { should have_alert(:danger) }
        end
      end # illegal date

    end # invalid info

    describe 'valid information' do
      before do
        fill_in 'Name', with: name
        select_datetime(now, 'Start')
        select tournament_type, from: 'Tournament type'
      end

      it "should create a tournament" do
        expect { click_button submit }.to change(Tournament, :count).by(1)
      end

      describe 'redirects properly', type: :request do
        before do
          login creator, avoid_capybara: true
          post contest_tournaments_path(contest),
            tournament: { name: name,
              start: now.strftime("%F %T"),
              tournament_type: tournament_type.downcase
          }
        end

        specify { expect(response).to redirect_to(tournament_path(assigns(:tournament))) }
      end # redirects

      describe "after submission" do
        let (:tournament) { Tournament.find_by(name: name) }

        before { click_button submit }

        specify { expect(tournament.contest.user).to eq(creator) }

        it { should have_alert(:success, text: 'Tournament created') }
        it { should have_content(/less than a minute|1 minute/) }
        it { should have_content(name) }
        it { should have_content(tournament.status) }
        it { should have_link(tournament.contest.name,
                              href: contest_path(tournament.contest) ) }
        it { should have_link(tournament.referee.name,
                              href: referee_path(tournament.referee) ) }
        it { should have_content("Players") }

      end
    end # valid info
  end # create
end
