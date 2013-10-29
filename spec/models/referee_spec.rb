require 'spec_helper'

describe Referee do
  let (:referee) { FactoryGirl.create(:referee) }
  subject { referee }

  it { should respond_to(:code_path) }
  it { should respond_to(:programming_language) }
  it { should respond_to(:contests) }

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:programming_language) }
  end
end
