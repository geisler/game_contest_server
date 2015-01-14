require 'spec_helper'

include ActionView::Helpers::DateHelper

describe "MatchesPages" do
  subject { page }

#Begin Devin's work
#  describe "create" do
#    let (:creator) { FactoryGirl.create(:contest_creator) }
#    let (:contest) { FactoryGirl.create(:contest, user: creator) }
#    let (:player1) { FactoryGirl.create(:player, contest: contest) }
#    let (:player2) { FactoryGirl.create(:player, contest: contest) }
#
#    let (:now) { Time.current }
#    let (:submit) { 'Challenge!' }  
#
#    before do
#      login creator
#      #I believe this is the page to create a challenge match
#      visit new_contest_match_path(contest)
#    end
#
#    describe "invalid information" do
#      describe "missing information" do
#        it "should not create a match" do
#          expect { click_button submit }.not_to change(Match, :count)
#        end
#
#        describe "after submission" do
#          before { click_button submit }
#
#          it { should have_alert(:danger) }
#        end
#      end
#    end # invalid info
#
#    describe "valid information" do
#
#      before do
#        select_datetime(now, 'Start')
#        check("#{player1.name} | #{player1.user.username}")
#        check("#{player2.name} | #{player2.user.username}")
#      end
#
#      it "should create a match" do
#        expect { click_button submit }.to change(Match, :count).by(1)
#      end    
#
#      describe 'redirects properly', type: :request do
#        before do
#          login creator, avoid_capybara: true
#          post contest_matches_path(contest),
#            match: { earliest_start: now.strftime("%F %T"),
#              players: [player1, player2]
#          }
#        end
#
#        specify { expect(response).to redirect_to(contest_path(assigns(:contest))) }
#      end # redirects

#      describe "after submission" do
        ###let (:match) { Match.find_by(name: name) }

#        before { click_button submit }

#        specify { expect(match.contest.user).to eq(creator) }

#        it { should have_alert(:success, text: 'Match created.') }
        ###it { should have_content(/less than a minute|1 minute/) }
        ###it { should have_content(tournament.status) }
        ###it { should have_link(tournament.contest.name,
                              ###href: contest_path(tournament.contest)) }
        ###it { should have_link(tournament.referee.name,
                              ###href: referee_path(tournament.referee)) }
        ###it { should have_content("Player") }
        ###it { should have_link(player1.name,
                              ###href: player_path(player1)) }
        ###it { should_not have_link(player2.name,
                              ###href: player_path(player2)) }

#      end

#    end #valid

#  end #create

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
