require 'rails_helper'

include ActionView::Helpers::DateHelper

describe "MatchesPages" do
  subject { page }

#Begin Devin's work
  describe "create" do
    let (:creator) { FactoryGirl.create(:contest_creator) }
    let (:contest) { FactoryGirl.create(:contest, user: creator) }
    let! (:player1) { FactoryGirl.create(:player, contest: contest, user: creator) }
    let! (:player2) { FactoryGirl.create(:player, contest: contest) }
    let! (:player3) { FactoryGirl.create(:player, contest: contest) }
    let! (:player4) { FactoryGirl.create(:player, contest: contest) }
    let! (:player5) { FactoryGirl.create(:player, contest: contest) }

    let (:now) { Time.current }
    let (:submit) { 'Challenge!' }  

    before do
      login creator
      visit new_contest_match_path(contest)
    end

    describe "invalid information" do
      describe "missing information" do
        it "should not create a match" do
          expect { click_button submit }.not_to change(Match, :count)
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
            select_illegal_datetime('Start', date)
	    check("#{player1.name} | #{player1.user.username}")
	    check("#{player2.name} | #{player2.user.username}")
	    check("#{player3.name} | #{player3.user.username}")
	    check("#{player4.name} | #{player4.user.username}")
            click_button submit
          end

          it { should have_alert(:danger) }
        end
      end # illegal date
      
      # Test that one of the current user's players are chosen
      describe "didn't select a current user's player" do
        before do
	  select_datetime(now, 'Start')
          check("#{player2.name} | #{player2.user.username}")
          check("#{player3.name} | #{player3.user.username}")
          check("#{player4.name} | #{player4.user.username}")
          check("#{player5.name} | #{player5.user.username}")
	  click_button submit
	end
	
	it { should have_alert(:danger) }

      end # no current user's player	

    end # invalid info

    describe "valid information" do

      before do
	select_datetime(now, 'Start')
        check("#{player1.name} | #{player1.user.username}")
        check("#{player2.name} | #{player2.user.username}")
        check("#{player3.name} | #{player3.user.username}")
        check("#{player4.name} | #{player4.user.username}")
      end

      it "should create a match" do
        expect { click_button submit }.to change(Match, :count).by(1)
      end    

      describe 'redirects properly', type: :request do
        before do
          login creator, avoid_capybara: true
          post contest_matches_path(contest),
            match: { earliest_start: now.strftime("%F %T"),
            player_ids: {player1.id => "1", player2.id => "1", player3.id => "1", player4.id => "1"} }
        end

        specify { expect(response).to redirect_to(match_path(assigns(:match))) }
	specify { expect(assigns(:match).manager).to eq(contest) }	

      end # redirects

      describe "after submission" do
        before { click_button submit }

	it { should have_content('Match Information') }
        it { should have_alert(:success, text: 'Match created.') }
        it { should have_content(/less than a minute|1 minute/) }
        it { should have_content('waiting') }
        it { should have_link(contest.name,
                              href: contest_path(contest)) }
        it { should have_content(contest.referee.name) }
        it { should have_content("4 Players") }
        it { should have_link(player1.name,
                              href: player_path(player1)) }
        it { should have_link(player2.name,
                              href: player_path(player2)) }
        it { should have_link(player3.name,
                              href: player_path(player3)) }
        it { should have_link(player4.name,
                              href: player_path(player4)) }
        it { should_not have_link(player5.name,
                              href: player_path(player5)) }

      end

    end #valid

  end #create

#End Devin's work

  describe "show (tournament matches)" do
    let (:match) { FactoryGirl.create(:tournament_match) }

    before { visit match_path(match) }

    it { should have_content(match.status) }
    it { should have_content(distance_of_time_in_words_to_now(match.earliest_start)) }
    it { should have_content(match.manager.name) }
    it { should have_content(match.manager.referee.name) }
    it { should have_content(match.manager.referee.players_per_game) }

    describe "completed" do
      before do
        match.status = 'completed'
        match.completion = 1.day.ago
        match.save

        visit match_path(match)
      end

      it { should have_content(distance_of_time_in_words_to_now(match.completion)) }
    end

    describe "associated players (descending scores)" do
      let!(:players) { [] }

      before do
        match.player_matches.each_with_index do |pm, i|
          pm.score = 10 - i
          pm.save
        end

        visit match_path(match)
      end

      it "should link to all players" do
        match.players.each_with_index do |p, i|
          selector = "//ol/li[position()=#{i + 1}]"
          should have_selector(:xpath, selector, text: p.name)
          should have_link(p.name, player_path(p))
          should have_selector(:xpath, selector, text: (10 - i).to_s)
        end
      end
    end

    describe "associated players (ascending scores)" do
      before do
        match.player_matches.each_with_index do |pm, i|
          pm.score = 10 + i
          pm.save
        end

        visit match_path(match)
      end

      it "should link to all players" do
        match.players.each_with_index do |p, i|
          selector = "//ol/li[position()=#{match.players.size - i}]"
          should have_selector(:xpath, selector, text: p.name)
          should have_link(p.name, player_path(p))
          should have_selector(:xpath, selector, text: (10 + i).to_s)
        end
      end
    end
  end

  describe "show (challenge matches)" do
    let (:match) { FactoryGirl.create(:challenge_match) }

    before { visit match_path(match) }

    it { should have_content(match.status) }
    it { should have_content(distance_of_time_in_words_to_now(match.earliest_start)) }
    it { should have_content(match.manager.name) }
    it { should have_content(match.manager.referee.name) }
    it { should have_content(match.manager.referee.players_per_game) }
  end

  ###NOTE Does this actually show all, given our addition of challenge functionality?
  describe "show all" do
    let (:tournament) { FactoryGirl.create(:tournament) }

    before do
      5.times { FactoryGirl.create(:tournament_match, manager: tournament) }

      visit tournament_matches_path(tournament)
    end

    it "lists all the matches for a contest in the system" do
      Match.where(manager: tournament).each do |m|
        should have_selector('li', text: m.id)
        should have_link(m.id, match_path(m))
      end
    end
  end
end
