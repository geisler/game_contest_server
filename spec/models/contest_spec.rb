require 'spec_helper'

describe Contest do
  let (:contest) { FactoryGirl.create(:contest) }
  subject { contest }

  # Tables
  it { should respond_to(:user) }
  it { should respond_to(:referee) }
  it { should respond_to(:players) }
  it { should respond_to(:tournaments) }
  # Attributes
  it { should respond_to(:deadline) }
  it { should respond_to(:description) }
  it { should respond_to(:name) }

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


  describe "empty description" do
    before { contest.description = '' }
    it { should_not be_valid }
  end

  describe "blank description" do
    before { contest.description = ' ' }
    it { should_not be_valid }
  end

  describe "duplicate description" do
    let (:other_contest) { FactoryGirl.create(:contest) }

    before { contest.description = other_contest.description }

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


  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:referee) }
    specify { expect_required_attribute(:user) }
  end
end
