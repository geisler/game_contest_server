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

      describe "followed by logout" do
	before { click_link 'Log Out' }

	it { should have_link('Log In', href: login_path) }
	it { should_not have_link('Log Out', href: logout_path) }
      end
    end
  end
end

describe "AuthorizationPages" do
  subject { page }

  describe "non-authenticated users" do
    let(:user) { FactoryGirl.create(:user) }

    describe "for Users controller" do
      describe "edit action" do
	before { visit edit_user_path(user) }

	it { should have_selector('div.alert.alert-warning', text: 'Unable') }
	it { should have_content('Log In') }
      end

      describe "update action", type: :request do
	before { patch user_path(user) }

	specify { expect(response).to redirect_to(login_path) }
      end
    end
  end

  describe "authenticated, but wrong user" do
    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    before { login user, avoid_capybara: true }

    describe "edit action", type: :request do
      before { get edit_user_path(other_user) }

      specify { expect(response.body).not_to match('Edit user') }
      specify { expect(response).to redirect_to(root_path) }
    end

    describe "update action", type: :request do
      before { patch user_path(other_user) }

      specify { expect(response).to redirect_to(root_path) }
    end
  end
end
