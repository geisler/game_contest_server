require 'spec_helper'

describe Player do
  let (:player) { FactoryGirl.create(:player) }
  subject { player }

  # Tables
  it { should respond_to(:user) }
  it { should respond_to(:contest) }
  it { should respond_to(:player_tournaments) }
  it { should respond_to(:tournaments) }
  it { should respond_to(:player_matches) }
  it { should respond_to(:matches) }
  # Attributes
  it { should respond_to(:file_location) }
  it { should respond_to(:description) }
  it { should respond_to(:name) }
  it { should respond_to(:downloadable) }
  it { should respond_to(:playable) }

  describe "blank file_location" do
    before { player.file_location = ' ' }

    it { should_not be_valid }
  end

  describe "empty file_location" do
    before { player.file_location = '' }

    it { should_not be_valid }
  end

  describe "file_location points to non-existant file" do
    before { player.file_location = '/path/to/non/existant/file' }

    it { should_not be_valid }
  end

  describe "blank description" do
    before { player.description = ' ' }

    it { should_not be_valid }
  end

  describe "empty description" do
    before { player.description = '' }

    it { should_not be_valid }
  end

  describe "blank name" do
    before { player.name = ' ' }

    it { should_not be_valid }
  end

  describe "empty name" do
    before { player.name = '' }

    it { should_not be_valid }
  end

  describe "duplicate name" do
    describe "different contests" do
      let (:other_player) { FactoryGirl.create(:player) }

      before { player.name = other_player.name }

      it { should be_valid }
    end

    describe "same contest" do
      let (:other_player) { FactoryGirl.create(:player, contest: player.contest) }

      before { player.name = other_player.name }

      it { should_not be_valid }
    end
  end

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:user) }
    specify { expect_required_attribute(:contest) }
  end
end
