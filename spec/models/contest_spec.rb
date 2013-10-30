require 'spec_helper'

describe Contest do
  let (:contest) { FactoryGirl.create(:contest) }
  subject { contest }

  it { should respond_to(:user) }
  it { should respond_to(:referee) }
  it { should respond_to(:description) }
  it { should respond_to(:deadline) }
  it { should respond_to(:start) }
  it { should respond_to(:name) }
  it { should respond_to(:contest_type) }
  it { should respond_to(:players) }
  it { should respond_to(:matches) }

  describe "validations" do
    it { should be_valid }
    specify { expect_required_attribute(:referee) }
    specify { expect_required_attribute(:user) }
  end
end
