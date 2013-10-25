require 'spec_helper'

describe "AuthenticationPages" do
  subject { page }
  describe "login page" do
    before { visit login_path }

    it { should have_content('Log In') }

    describe "with invalid account" do
      before { click_button 'Log In' }

      it { should have_alert(:danger, text: 'Invalid') }

      describe "visiting another page" do
	before { click_link 'Home' }

	it { should_not have_alert(:danger) }
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
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Log Out', href: logout_path) }
      it { should_not have_link('Log In', href: login_path) }
      it { should_not have_link('Sign Up', href: signup_path) }

      it { should have_alert(:success) }

      describe "followed by logout" do
	before { click_link 'Log Out' }

	it { should have_link('Log In', href: login_path) }
	it { should have_link('Sign Up', href: signup_path) }
	it { should_not have_link('Log Out', href: logout_path) }
	it { should_not have_link('Profile') }

	it { should have_alert(:info) }
      end
    end
  end
end

describe "AuthorizationPages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }

  describe "non-authenticated users" do
    describe "for Users controller" do
      describe "edit action" do
	before { visit edit_user_path(user) }

	it { should have_alert(:warning) }
	it { should have_content('Log In') }
      end

      describe "update action", type: :request do
	before { patch user_path(user) }

	it { errors_on_redirect(login_path, :warning) }
      end
    end
  end

  describe "authenticated users" do
    before { login user, avoid_capybara: true }

    describe "new action", type: :request do
      before { get new_user_path }

      it { errors_on_redirect(root_path, :warning) }
    end

    describe "create action", type: :request do
      before { post users_path }

      it { errors_on_redirect(root_path, :warning) }
    end
  end

  describe "authenticated, but wrong user" do
    let(:other_user) { FactoryGirl.create(:user) }

    before { login user, avoid_capybara: true }

    describe "edit action", type: :request do
      before { get edit_user_path(other_user) }

      specify { expect(response.body).not_to match('Edit user') }
      it { errors_on_redirect(root_path, :danger) }
    end

    describe "update action", type: :request do
      before { patch user_path(other_user) }

      it { errors_on_redirect(root_path, :danger) }
    end
  end

  describe "authenticated, but non-admin user" do
    let(:other_user) { FactoryGirl.create(:user) }

    before { login user, avoid_capybara: true }

    describe "update action", type: :request do
      before { patch user_path(other_user) }

      it { errors_on_redirect(root_path, :danger) }
    end
  end

  describe "authenticated admin user" do
    let(:admin) { FactoryGirl.create(:admin) }

    describe "delete action (self)", type: :request do
      before do
	login admin, avoid_capybara: true
	delete user_path(admin)
      end

      it { errors_on_redirect(root_path, :danger) }
    end

    pending "edit action (other)" do
    end

    pending "update action (other)", type: :request do
    end
  end
end
