require 'spec_helper'

describe Match do
  let (:match) { FactoryGirl.create(:contest_match) }
  subject { match }

  it { should respond_to(:completion) }
  it { should respond_to(:earliest_start) }
  it { should respond_to(:player_matches) }
  it { should respond_to(:players) }
  it { should respond_to(:manager) }
  it { should respond_to(:status) }

  describe "empty status" do
    before { match.status = '' }

    it { should_not be_valid }
  end

  describe "blank status" do
    before { match.status = ' ' }

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

  describe "exactly right players" do
    before do
      match.players.clear
      match.manager.referee.players_per_game.times do
	match.players << FactoryGirl.create(:player, contest: match.manager)
      end
    end

    it { should be_valid }
  end

  describe "too many players" do
    before do
      match.players.clear
      (match.manager.referee.players_per_game + 1).times do
	match.players << FactoryGirl.create(:player, contest: match.manager)
      end
    end

    it { should_not be_valid }
  end
end
