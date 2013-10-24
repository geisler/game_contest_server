require 'spec_helper'

describe MatchType do
  let (:match_type) { FactoryGirl.create(:match_type) }
  subject { match_type }

  it { should respond_to(:kind) }
end
