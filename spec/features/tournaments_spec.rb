require 'spec_helper'

describe 'TournamentsPages' do
  let (:creator) { FactoryGirl.create(:contest_creator) }
  let!(:referee) { FactoryGirl.create(:referee) }
  let (:contest) { FactoryGirl.create(:contest, user: creator) }
  let!(:player1) { FactoryGirl.create(:player, contest: contest) }
  let!(:player2) { FactoryGirl.create(:player, contest: contest) }

  let (:name) { 'Test Tournament' }
  let (:now) { Time.current }
  let (:tournament_type) { 'Round Robin' }

  let (:edit_name) { 'Some random edited name' }
  let (:edit_time) { now + 1.day }
  let (:edit_tournament_type) { 'Single Elimination' }

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
=begin
        puts "****************** BODY ****************"
        puts page.body
        puts
        puts
        puts
        puts "!!!!!!!!!!!!!!!!!!!!!!!!!!! AQUI !!!!!!!!!!!!!!!!!!!!!!!!!"
        puts "player1: #{player1}"
        puts
        puts
        puts
=end
        check("#{player1.name} | #{player1.user.username}")


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
              tournament_type: tournament_type.downcase,
              players: [player1]
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
                              href: contest_path(tournament.contest)) }
        it { should have_link(tournament.referee.name,
                              href: referee_path(tournament.referee)) }
        it { should have_content("Players") }
        it { should have_link(player1.name,
                              href: player_path(player1)) }
        it { should_not have_link(player2.name,
                              href: player_path(player2)) }

      end
    end # valid info
  end # create

  describe "edit" do
    let (:tournament) { FactoryGirl.create(:tournament, contest: contest) }
    let!(:orig_name) { tournament.name }
    let (:submit) { 'Update Tournament' }

    before do
      tournament.players << player1
      player1.tournaments << tournament
      login creator
      visit edit_tournament_path(tournament)
    end

    it { should have_field('Name', with: tournament.name) }
    it { expect_datetime_select(tournament.start, 'Start') }
    it { should have_select('Tournament type', selected: tournament.tournament_type) }

    it { should have_checked_field("#{player1.name} | #{player1.user.username}") }
    it { should_not have_unchecked_field("#{player1.name} | #{player1.user.username}") }

    it { should_not have_checked_field("#{player2.name} | #{player2.user.username}") }
    it { should have_unchecked_field("#{player2.name} | #{player2.user.username}") }

    describe "with invalid information" do
      before do
        select_datetime(now, 'Start')
        fill_in 'Name', with: ''
        select tournament_type, from: 'Tournament type'
      end

      describe "does not change data" do
        before { click_button submit }

        specify { expect(tournament.reload.name).not_to eq('') }
        specify { expect(tournament.reload.name).to eq(orig_name) }
      end

      it "does not add a new tournament to the system" do
        expect { click_button submit }.not_to change(Tournament, :count)
      end

      it "produces an error message" do
        click_button submit
        should have_alert(:danger)
      end
    end # invalid info

    # Users should NOT be able to change the status of a
    # tournament. This is done by the backend and it uses it
    # to determine when to run tournaments.
    # The tournament model needs to be changed to reflect this.
    describe "with forbidden attributes", type: :request do
      %w[ waiting completed ].each do |new_status|
        describe "change status to #{new_status}" do
          before do
            tournament.status = 'started'
            login creator, avoid_capybara: true
            patch tournament_path(tournament), tournament: { status: new_status  }
          end

          specify { expect(tournament.reload.status).not_to eq(new_status) }
        end # change status to #{new_status}
      end # do loop


    end # forbidden attributes

    describe "with valid information" do
      let (:new_name) { 'Some random new name' }
      let (:new_tournament_type) { 'Single Elimination' }

      before do
        fill_in 'Name', with: edit_name
        select_datetime(edit_time, 'Start')
        select edit_tournament_type, from: 'Tournament type'
        uncheck ("#{player1.name} | #{player1.user.username}")
        check ("#{player2.name} | #{player2.user.username}")
      end

      describe "changes the data" do
        before { click_button submit }

        it { should have_alert(:success) }
        specify { expect(tournament.reload.name).to eq(edit_name) }
        specify { expect_same_minute(tournament.reload.start, edit_time) }
        # specify { expect(contest.reload.description).to eq(description) }
        specify { expect(tournament.reload.tournament_type).to eq(edit_tournament_type.downcase) }

        it { should_not have_link(player1.name,
                                  href: player_path(player1)) }
        it { should have_link(player2.name,
                              href: player_path(player2)) }
      end # changes the data

      describe "redirects properly", type: :request do
        before do
          login creator, avoid_capybara: true
          patch tournament_path(tournament), tournament: { start: now.strftime("%F %T"),
            name: edit_name,
            tournament_type: edit_tournament_type.downcase
          }
        end

        specify { expect(response).to redirect_to(tournament_path(tournament)) }
      end # redirects properly

      it "does not add a new tournament to the system" do
        expect { click_button submit }.not_to change(Tournament, :count)
      end

    end # valid information


  end # edit
end





























