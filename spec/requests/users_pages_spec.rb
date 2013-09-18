require 'spec_helper'

describe "UsersPages" do
  describe "Sign Up" do
    let(:submit) { 'Create new account' }

    before do
      visit signup_path
      fill_in 'Username', with: 'User Name'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'password'
      fill_in 'Confirmation', with: 'password'
    end

    it "allows the user to fill in name and password" do
      click_button submit
    end

    it "adds a new user to the system" do
      expect { click_button submit }.to change(User, :count).by(1)
    end
  end
end
