require 'spec_helper'

describe Match do
  let (:match) { FactoryGirl.create(:tournament_match) }
  subject { match }

  # Tables
  it { should respond_to(:players) }
  it { should respond_to(:player_matches) }
  it { should respond_to(:manager) }
  # Attributes
  it { should respond_to(:manager_type) }
  it { should respond_to(:status) }
  it { should respond_to(:earliest_start) }
  it { should respond_to(:completion) }

  describe "empty status" do
    before { match.status = '' }

    it { should_not be_valid }
  end

  describe "blank status" do
    before { match.status = ' ' }

    it { should_not be_valid }
  end

  describe "valid statuses" do
    valid_statuses = %w[waiting pending completed]
    valid_statuses.each do |status|
      it "is valid" do
        match.status = status
        expect(match).to be_valid
      end
    end
  end

  describe "invalid statuses" do
    invalid_statuses = %w[
      Waiting Pending Completed
      wait pend complete
      w p c
      before during after
      ]
    invalid_statuses.each do |status|
      it "is invalid" do
        match.status = status
        expect(match).not_to be_valid
      end
    end
  end

  describe "empty earliest_start" do
    describe "waiting" do
      before do
        match.status = 'Waiting'
        match.earliest_start = ''
      end

      it { should_not be_valid }
    end

    describe "started" do
      before do
        match.status = 'Started'
        match.earliest_start = ''
      end

      it { should be_valid }
    end

    describe "completed" do
      before do
        match.status = 'Completed'
        match.earliest_start = ''
      end

      it { should be_valid }
    end
  end

  describe "blank earliest_start" do
    describe "waiting" do
      before do
        match.status = 'Waiting'
        match.earliest_start = ' '
      end

      it { should_not be_valid }
    end

    describe "started" do
      before do
        match.status = 'Started'
        match.earliest_start = ' '
      end

      it { should be_valid }
    end

    describe "completed" do
      before do
        match.status = 'Completed'
        match.earliest_start = ' '
      end

      it { should be_valid }
    end
  end

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:manager) }
  end

  describe "too few players" do
    before { match.players.clear }

    it { should_not be_valid }
  end

  describe "completion in past" do
    before do
      match.status = 'Completed'
      match.completion = 1.day.ago
    end

    it { should be_valid }
  end

  describe "completion now" do
    before do
      match.status = 'Completed'
      match.completion = Time.current
    end

    it { should be_valid }
  end

  describe "completion in future" do
    before do
      match.status = 'Completed'
      match.completion = 1.day.from_now
    end

    it { should_not be_valid }
  end

  describe "not completed in future" do
    before do
      match.completion = 1.day.from_now
    end

    it { should be_valid }
  end

  describe "too few players" do
    before do
      match.players.clear
      (match.manager.referee.players_per_game - 1).times do
        #match.players << FactoryGirl.create(:player, tournaments: [match.manager])
        player = FactoryGirl.create(:player, contest: match.manager.contest)
        player.tournaments << match.manager
        match.players << player
      end
    end

    it { should_not be_valid }
  end

  describe "exactly right players" do
    before do
      match.players.clear
      match.manager.referee.players_per_game.times do
        match.players << FactoryGirl.create(:player_with_tournament)
      end
    end

    it { should be_valid }
  end

  describe "too many players" do
    before do
      match.players.clear
      (match.manager.referee.players_per_game + 1).times do
        match.players << FactoryGirl.create(:player, tournaments: [match.manager])
      end
    end

    it { should_not be_valid }
  end

  # This is a kinda confusing test.
  # It makes players that are in the same contest
  # but not in the same tournament try to play in the same 
  # match in a tournament, which should not be allowed.
  describe "players in same contest, but not in same tournament" do
    before do
      puts "players in same contest, but not in same tournament"
      match.players.clear
      contest = FactoryGirl.create(:contest)
      match.manager.referee.players_per_game.times do
        player = FactoryGirl.create(:player)
        player.contest = contest
        player.tournaments = FactoryGirl.create_list(:tournament, 1, contest: contest)
=begin
        # The proof is in the puts
        puts "player.name        " + player.name
        puts "player.contest_id  " + player.contest_id.to_s
        puts "player.tournaments " + player.tournaments[0].id.to_s
=end
        match.players << player
      end
    end

    it { should_not be_valid }
  end

  # This is another kinda confusing test.
  # It makes players that are in different contests try to play
  # in the same match in a tournament, which should not be allowed.
  describe "players in different contests" do
    before do
      puts "players in different contest"
      match.players.clear
      match.manager.referee.players_per_game.times do
        player = FactoryGirl.create(:player)
        player.tournaments = FactoryGirl.create_list(:tournament, 1, contest: player.contest)
=begin
        # The proof is in the puts
        puts "player.name        " + player.name
        puts "player.contest_id  " + player.contest_id.to_s
        puts "player.tournaments " + player.tournaments[0].id.to_s
=end
        match.players << player
      end
    end

    it { should_not be_valid }
  end
end
