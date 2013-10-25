require 'spec_helper'

describe MatchType do
  let (:match_type) { FactoryGirl.create(:match_type) }
  subject { match_type }

  it { should respond_to(:kind) }
  it { should respond_to(:matches) }

  describe "validations" do
    it { should be_valid }
  end
end
