require 'spec_helper'

describe ProgrammingLanguage do
  let (:programming_language) { FactoryGirl.create(:programming_language) }
  subject { programming_language }

  it { should respond_to(:name) }
  it { should respond_to(:contest_managers) }
  it { should respond_to(:players) }

  describe "validations" do
    it { should be_valid }
  end
end
