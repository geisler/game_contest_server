require 'spec_helper'

describe Tournament do
=begin
describe Contest do
  let (:contest) { FactoryGirl.create(:contest) }
  subject { contest }
=end

  describe "empty start" do
    before { tournament.start = '' }
    it { should_not be_valid }
  end

  describe "blank start" do
    before { tournament.start = ' ' }
    it { should_not be_valid }
  end

  describe "start before deadline" do
    before { tournament.start = tournament.deadline - 1.second }

    it { should_not be_valid }
  end

  describe "start same as deadline" do
    before { tournament.start = tournament.deadline }

    it { should be_valid }
  end

  describe "start in past" do
    before { tournament.start = 1.day.ago }
    it { should_not be_valid }
  end

  describe "start now" do
    before { tournament.deadline = tournament.start = Time.current }
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
end
