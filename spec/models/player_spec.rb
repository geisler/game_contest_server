require 'spec_helper'

describe Player do
  let (:player) { FactoryGirl.create(:player) }
  subject { player }

  it { should respond_to(:user) }
  it { should respond_to(:contest) }
  it { should respond_to(:code_path) }
  it { should respond_to(:programming_language) }
  it { should respond_to(:player_matches) }
  it { should respond_to(:matches) }

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:user) }
    specify { expect_required_attribute(:contest) }
    specify { expect_required_attribute(:programming_language) }
  end
end
