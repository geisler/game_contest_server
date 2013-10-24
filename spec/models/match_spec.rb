require 'spec_helper'

describe Match do
  let (:match) { FactoryGirl.create(:match) }
  subject { match }

  it { should respond_to(:contest) }
  it { should respond_to(:occurance) }
  it { should respond_to(:match_type) }
  it { should respond_to(:duration) }
  it { should respond_to(:player_matches) }
  it { should respond_to(:players) }
end
