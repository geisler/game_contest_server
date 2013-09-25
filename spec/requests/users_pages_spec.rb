require 'spec_helper'

describe "UsersPages" do
  describe "Sign Up" do
    let(:submit) { 'Create new account' }

    before { visit signup_path }

    describe "with invalid information" do
      it "does not add the user to the system" do
	expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in 'Username', with: 'User Name'
        fill_in 'Email', with: 'user@example.com'
        fill_in 'Password', with: 'password'
        fill_in 'Confirmation', with: 'password'
      end

      it "allows the user to fill in user fields" do
        click_button submit
      end

      it "adds a new user to the system" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
    end
  end
end
