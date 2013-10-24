require 'spec_helper'

describe ProgrammingLanguage do
  let (:programming_language) { FactoryGirl.create(:programming_language) }
  subject { programming_language }

  it { should respond_to(:name) }
end
