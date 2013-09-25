require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }
  subject { user }

  it { should respond_to(:username) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }

  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }

  describe "empty username" do
    before { user.username = '' }
    it { should_not be_valid }
  end

  describe "blank username" do
    before { user.username = ' ' }
    it { should_not be_valid }
  end

  describe "empty email" do
    before { user.email = '' }
    it { should_not be_valid }
  end

  describe "blank email" do
    before { user.email = ' ' }
    it { should_not be_valid }
  end
end
