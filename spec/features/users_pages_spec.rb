require 'spec_helper'

describe "UsersPages" do
  subject { page }

  describe "Sign Up" do
    let(:submit) { 'Create new account' }

    before { visit signup_path }

    describe "passwords are not visible when typing" do
      it { should have_field 'user_password', type: 'password' }
      it { should have_field 'user_password_confirmation', type: 'password' }
    end

    describe "with invalid information" do
      it "does not add the user to the system" do
	expect { click_button submit }.not_to change(User, :count)
      end

      it "produces an error message" do
	click_button submit
	should have_alert(:danger)
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

      describe "redirects properly", type: :request do
	before do
	  post users_path, user: { username: 'User Name',
				   email: 'user@example.com',
				   password: 'password',
				   password_confirmation: 'password' }
        end

	specify { expect(response).to redirect_to(user_path(assigns(:user))) }
      end

      it "adds a new user to the system" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after creating the user" do
	before { click_button submit }

	it { should have_link('Log Out') }
	it { should_not have_link('Log In') }
	it { should have_alert(:success, text: 'Welcome') }
      end
    end
  end

  describe "Display Users" do
    describe "individually" do
      let(:user) { FactoryGirl.create(:user) }

      before do
	5.times { FactoryGirl.create(:player, user: user) }

	visit user_path(user)
      end

      it { should have_content(user.username) }
      it { should have_content(user.email) }
      it { should_not have_content(user.password) }
      it { should_not have_content(user.password_digest) }

      it { should have_selector('h2', text: 'Players') }
      it "lists all the players for the user" do
	Player.all.each do |player|
	  should have_selector('li', text: player.name)
	  should_not have_link('delete', href: player_path(player))
	end
      end
      #it { should have_link('New Player', href: new_player_path) }
      it { should have_content('5 players') }

      it { should_not have_selector('h2', text: 'Referees') }
      it { should_not have_link('New Referee', href: new_referee_path) }

      describe "logged in" do
	before do
	  login user
	  visit user_path(user)
	end

	it "gives delete links to all the players for the user" do
	  Player.all.each do |player|
	    should have_link('delete', href: player_path(player))
	  end
	end
      end
    end

    describe "individually (contest creator)" do
      let(:user) { FactoryGirl.create(:contest_creator) }

      before do
	5.times { FactoryGirl.create(:referee, user: user) }

	visit user_path(user)
      end

      it { should have_selector('h2', text: 'Referees') }
      it "lists all the referees for the user" do
	Referee.all.each do |ref|
	  should have_selector('li', text: ref.name)
	  should_not have_link('delete', href: referee_path(ref))
	end
      end
      it { should have_link('New Referee', href: new_referee_path) }
      it { should have_content('5 referees') }

      describe "logged in" do
	before do
	  login user
	  visit user_path(user)
	end

	it "gives delete links to all the referees for the user" do
	  Referee.all.each do |ref|
	    should have_link('delete', href: referee_path(ref))
	  end
	end
      end
    end

    describe "individually (admin)" do
    end

    describe "all" do
      before(:all) { 25.times { FactoryGirl.create(:user) } }
      after(:all) { User.all.each { |user| user.destroy } }

      before(:each) { visit users_path }

      it { should have_content('List of users') }
      it { should have_content('25 users') }

      # fix up with pagination later...
      User.all.each do |user|
	it { should have_selector('li', text: user.username) }
      end
    end
  end

  describe "Edit users" do
    let (:user) { FactoryGirl.create(:user) }
    let!(:orig_username) { user.username }
    let (:submit) { 'Update account' }

    before do
      login user
      visit edit_user_path(user)
    end

    it { should have_field('Username', with: user.username) }
    it { should have_field('Email', with: user.email) }
    it { should_not have_field('Password', with: user.password) }

    describe "with invalid information" do
      before do
	fill_in 'Username', with: ''
	fill_in 'Email', with: user.email
	fill_in 'Password', with: user.password
	fill_in 'Confirmation', with: user.password
      end

      describe "does not change data" do
        before { click_button submit }

        specify { expect(user.reload.username).not_to eq('') }
        specify { expect(user.reload.username).to eq(orig_username) }
      end

      it "does not add a new user to the system" do
        expect { click_button submit }.not_to change(User, :count)
      end

      it "produces an error message" do
	click_button submit
	should have_alert(:danger)
      end
    end

    describe "with forbidden attributes", type: :request do
      before do
	login user, avoid_capybara: true
	patch user_path(user), user: { admin: true,
				       password: user.password,
				       password_confirmation: user.password }
      end

      specify { expect(user.reload).not_to be_admin }
    end

    describe "with valid information" do
      before do
	fill_in 'Username', with: 'Changed name'
	fill_in 'Email', with: 'new@example.com'
	fill_in 'Password', with: user.password
	fill_in 'Confirmation', with: user.password
      end

      describe "changes the data" do
        before { click_button submit }

        specify { expect(user.reload.username).to eq('Changed name') }
        specify { expect(user.reload.email).to eq('new@example.com') }
      end

      describe "redirects properly", type: :request do
	before do
	  login user, avoid_capybara: true
	  patch user_path(user), user: { username: 'Changed name',
					 email: user.email,
					 password: user.password,
					 password_confirmation: user.password }
        end

	specify { expect(response).to redirect_to(user_path(user)) }
      end

      it "produces an update message" do
	click_button submit
	should have_alert(:success)
      end

      it "does not add a new user to the system" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end
  end

  describe "Delete users" do
    describe "as anonymous" do
      let!(:user) { FactoryGirl.create(:user) }

      before { visit users_path }

      it { should_not have_link('delete') }
    end

    describe "as a user" do
      let (:user) { FactoryGirl.create(:user) }

      before do
	login user
	visit users_path
      end

      it { should_not have_link('delete') }
    end

    describe "as admin" do
      let (:admin) { FactoryGirl.create(:admin) }
      let!(:user) { FactoryGirl.create(:user) }

      before do
        login admin
        visit users_path
      end

      it { should have_link('delete', href: user_path(user)) }
      it { should_not have_link('delete', href: user_path(admin)) }

      describe "redirects properly", type: :request do
	before do
	  login admin, avoid_capybara: true
	  delete user_path(user)
	end

	specify { expect(response).to redirect_to(users_path) }
      end

      it "produces a delete message" do
	click_link('delete', match: :first)
	should have_alert(:success)
      end

      it "removes a user from the system" do
        expect { click_link('delete', match: :first) }.to change(User, :count).by(-1)
      end
    end
  end
end
