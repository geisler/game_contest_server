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
end
