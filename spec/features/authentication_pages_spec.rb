require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
  describe "login page" do
    before { visit login_path }

    it { should have_content('Sign in') }

    describe "with invalid account" do
      before { click_button 'Log In' }

      it { should have_selector('div.alert.alert-danger', text: 'Invalid') }

      describe "visiting another page" do
	before { click_link 'Home' }

	it { should_not have_selector('div.alert.alert-danger') }
      end
    end

    describe "with valid account" do
      let(:user) { FactoryGirl.create(:user) }

      before do
	fill_in 'Username', with: user.username
	fill_in 'Password', with: user.password
	click_button 'Log In'
      end

      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Log Out', href: logout_path) }
      it { should_not have_link('Log In', href: login_path) }
    end
  end
end
