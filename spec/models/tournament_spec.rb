require 'spec_helper'

describe Tournament do
  let (:tournament) { FactoryGirl.create(:tournament) }
  subject { tournament }

  # Tables
  it { should respond_to(:contest) }
  it { should respond_to(:player_tournaments) }
  it { should respond_to(:matches) }
  it { should respond_to(:players) }
  # Attributes
  it { should respond_to(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:start) }
  it { should respond_to(:tournament_type) }

  describe "empty name" do
    before { tournament.name = '' }
    it { should_not be_valid }
  end

  describe "blank name" do
    before { tournament.name = ' ' }
    it { should_not be_valid }
  end

  describe "duplicate name" do
    describe "same contest" do
      let (:other_tournament) { FactoryGirl.create(:tournament, contest: tournament.contest) }
      before { tournament.name = other_tournament.name }
      it { should_not be_valid }
    end

    describe "different contests" do
      let (:other_tournament) { FactoryGirl.create(:tournament) }
      before { tournament.name = other_tournament.name }
      it { should be_valid }
    end
  end

  describe "empty status" do
    before { tournament.status = '' }
    it { should_not be_valid }
  end

  describe "blank status" do
    before { tournament.status = ' ' }
    it { should_not be_valid }
  end

  describe "valid status" do
    valid_statuses = %w[waiting started completed]
    valid_statuses.each do |status|
      it "is valid" do
        tournament.status = status
        expect(tournament).to be_valid
      end
    end
  end

  describe "invalid status" do
    invalid_statuses = %w[
      Waiting Started Completed Pending
      wait start complete pend
      w s c p
      before during after
      ]
    invalid_statuses.each do |status|
      it "is invalid" do
        tournament.status = status
        expect(tournament).not_to be_valid
      end
    end
  end

  describe "empty start" do
    before { tournament.start = '' }
    it { should_not be_valid }
  end

  describe "blank start" do
    before { tournament.start = ' ' }
    it { should_not be_valid }
  end

  describe "start in past" do
    before { tournament.start = 1.day.ago }
    it { should be_valid }
  end

  describe "start in future" do
    before { tournament.start = 1.day.from_now }
    it { should be_valid }
  end

  describe "empty tournament type" do
    before { tournament.tournament_type = '' }
    it { should_not be_valid }
  end

  describe "blank tournament type" do
    before { tournament.tournament_type = ' ' }
    it { should_not be_valid }
  end

  describe "valid tournament type" do
    describe "round robin" do
      before { tournament.tournament_type = 'round robin' }
      it { should be_valid }
    end

    describe "single elimination" do
      before { tournament.tournament_type = 'single elimination' }
      it { should be_valid }
    end
  end

  describe "invalid tournament type" do
    before { tournament.tournament_type = 'bad type' }
    it { should_not be_valid }
  end

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:contest) }
  end
end
