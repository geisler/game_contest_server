require 'spec_helper'

describe Match do
  let (:match) { FactoryGirl.create(:contest_match) }
  subject { match }

  it { should respond_to(:completion) }
  it { should respond_to(:earliest_start) }
  it { should respond_to(:player_matches) }
  it { should respond_to(:players) }
  it { should respond_to(:manager) }

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:manager) }
  end
end
