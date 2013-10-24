require 'spec_helper'

describe PlayerMatch do
  let (:player_match) { FactoryGirl.create(:player_match) }
  subject { player_match }

  it { should respond_to(:player) }
  it { should respond_to(:match) }
  it { should respond_to(:score) }
end
