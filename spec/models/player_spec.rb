require 'spec_helper'

describe Player do
  let (:player) { FactoryGirl.create(:player) }
  subject { player }

  it { should respond_to(:user) }
  it { should respond_to(:contest) }
  it { should respond_to(:file_location) }
  it { should respond_to(:description) }
  it { should respond_to(:name) }
  it { should respond_to(:downloadable) }
  it { should respond_to(:playable) }
  it { should respond_to(:player_matches) }
  it { should respond_to(:matches) }

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:user) }
    specify { expect_required_attribute(:contest) }
  end
end
