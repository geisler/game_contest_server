require 'spec_helper'

describe "UsersPages" do
  describe "Sign Up" do
    it "allows the user to fill in name and password" do
      visit signup_path
      fill_in 'Username', with: 'user@example.com'
      fill_in 'Password', with: 'password'
      fill_in 'Confirmation', with: 'password'
      click_button 'Create new account'
    end
  end
end
