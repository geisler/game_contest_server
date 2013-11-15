require 'spec_helper'

describe Contest do
  let (:contest) { FactoryGirl.create(:contest) }
  subject { contest }

  it { should respond_to(:user) }
  it { should respond_to(:referee) }
  it { should respond_to(:description) }
  it { should respond_to(:deadline) }
  it { should respond_to(:start) }
  it { should respond_to(:name) }
  it { should respond_to(:contest_type) }
  it { should respond_to(:players) }
  it { should respond_to(:matches) }

  describe "empty deadline" do
    before { contest.deadline = '' }
    it { should_not be_valid }
  end

  describe "blank deadline" do
    before { contest.deadline = ' ' }
    it { should_not be_valid }
  end

  describe "deadline in past" do
    before { contest.deadline = 1.day.ago }
    it { should_not be_valid }
  end

  describe "deadline now" do
    before { contest.deadline = Time.current }
    it { should be_valid }
  end

  describe "deadline in future" do
    before { contest.deadline = 1.day.from_now }
    it { should be_valid }
  end

  describe "empty start" do
    before { contest.start = '' }
    it { should_not be_valid }
  end

  describe "blank start" do
    before { contest.start = ' ' }
    it { should_not be_valid }
  end

  describe "start before deadline" do
    before { contest.start = contest.deadline - 1.second }

    it { should_not be_valid }
  end

  describe "start same as deadline" do
    before { contest.start = contest.deadline }

    it { should be_valid }
  end

  describe "start in past" do
    before { contest.start = 1.day.ago }
    it { should_not be_valid }
  end

  describe "start now" do
    before { contest.deadline = contest.start = Time.current }
    it { should be_valid }
  end

  describe "start in future" do
    before { contest.start = 1.day.from_now }
    it { should be_valid }
  end

  describe "empty name" do
    before { contest.name = '' }
    it { should_not be_valid }
  end

  describe "blank name" do
    before { contest.name = ' ' }
    it { should_not be_valid }
  end

  describe "duplicate name" do
    let (:other_contest) { FactoryGirl.create(:contest) }

    before { contest.name = other_contest.name }

    it { should_not be_valid }
  end

  describe "empty contest type" do
    before { contest.contest_type = '' }
    it { should_not be_valid }
  end

  describe "blank contest type" do
    before { contest.contest_type = ' ' }
    it { should_not be_valid }
  end

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:referee) }
    specify { expect_required_attribute(:user) }
  end
end
