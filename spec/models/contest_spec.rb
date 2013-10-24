require 'spec_helper'

describe Contest do
  let (:contest) { FactoryGirl.create(:contest) }
  subject { contest }

  it { should respond_to(:user) }
  it { should respond_to(:contest_manager) }
  it { should respond_to(:description) }
  it { should respond_to(:documentation_path) }
  it { should respond_to(:players) }
  it { should respond_to(:matches) }
end
