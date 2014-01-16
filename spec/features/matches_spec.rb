require 'spec_helper'

include ActionView::Helpers::DateHelper

describe "MatchesPages" do
  subject { page }

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
