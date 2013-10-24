require 'spec_helper'

describe ContestManager do
  let (:contest_manager) { FactoryGirl.create(:contest_manager) }
  subject { contest_manager }

  it { should respond_to(:code_path) }
  it { should respond_to(:programming_language) }
end
