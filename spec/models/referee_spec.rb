require 'spec_helper'

describe Referee do
  let (:referee) { FactoryGirl.create(:referee) }
  subject { referee }

  it { should respond_to(:file_location) }
  it { should respond_to(:name) }
  it { should respond_to(:rules_url) }
  it { should respond_to(:players_per_game) }
  it { should respond_to(:contests) }
  it { should respond_to(:matches) }

  describe "validations" do
    it { should be_valid }
  end
end
