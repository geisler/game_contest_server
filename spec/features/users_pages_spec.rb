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

      it { should have_subheader(text: 'Players') }
      it "lists all the players for the user" do
        Player.all.each do |player|
          should have_selector('li', text: player.name)
          should_not have_link('delete', href: player_path(player))
        end
      end
      #it { should have_link('New Player', href: new_player_path) }
      it { should have_content('5 players') }

      it { should_not have_subheader(text: 'Referees') }
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

      it { should have_subheader(text: 'Referees') }
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
      before(:all) { 10.times { FactoryGirl.create(:user) } }
      after(:all) { User.all.each { |user| user.destroy } }

      before(:each) { visit users_path }

      it { should have_content('List of Users') }
      it { should have_content('10 users') }

      # fix up with pagination later...
      User.all.each do |user|
        it { should have_selector('li', text: user.username) }
      end
    end
  end
  
  describe "pagination" do
    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all)  { User.delete_all }
    
    before(:each) { visit users_path }
    
    it { should have_content('10 users') }
    it { should have_selector('div.pagination') }
    it { should have_link('2', href: "/?page=2" ) }
    it { should have_link('3', href: "/?page=3") }
    it { should_not have_link('4', href: "/?page=4") }     
  end
 
  
  describe 'searchError' do
    let(:submit) {"Search"}
    
    before do
      FactoryGirl.create(:user, username: "searchtest")
      visit users_path
      fill_in 'search', with:';'
      click_button submit
    end

    it 'should return results' do
      should have_content(' ')
      should have_alert(:info)
      
   end
   end
  
  describe 'search_error'do
    let(:submit) {"Search"}
    before do
      FactoryGirl.create(:user, username: "searchtest1")
      FactoryGirl.create(:user, username: "peter1")
      FactoryGirl.create(:user, username: "searchtest0")
      
      visit users_path
      fill_in 'search', with:':'
      click_button submit
    end
    after(:all)  { User.delete_all }
    it { should have_content("0 user") }
    it { should_not have_link('2') }#, href: "/contests?utf8=✓&direction=&sort=&search=searchtest4&commit=Search" ) } 
    it {should have_alert(:info) }
  end
  
  
  
  
  describe 'search_parcial' do
    let(:submit) {"Search"}
    before do
      FactoryGirl.create(:user, username: "searchtest1")
      FactoryGirl.create(:user, username: "peter1")
      FactoryGirl.create(:user, username: "searchtest0")
      FactoryGirl.create(:user, username: "peter0")
      FactoryGirl.create(:user, username: "searchtest9")
      FactoryGirl.create(:user, username: "peter9")
      FactoryGirl.create(:user, username: "searchtest4")
      FactoryGirl.create(:user, username: "peter4")
      FactoryGirl.create(:user, username: "searchtest5")
      FactoryGirl.create(:user, username: "peter5")
      FactoryGirl.create(:user, username: "searchtest6")
      FactoryGirl.create(:user, username: "peter6")
      FactoryGirl.create(:user, username: "searchtest7")
      FactoryGirl.create(:user, username: "peter7")
      FactoryGirl.create(:user, username: "searchtest8")
      FactoryGirl.create(:user, username: "peter8")
      visit users_path
      fill_in 'search', with:'te'
      click_button submit
    end
    after(:all)  { User.delete_all }
    it { should have_content("10 users") }
    it { should have_link('Next →') }#, href: "/?commit=Search&amp;direction=&amp;page=2&amp;search=te&amp;sort=&amp;utf8=%E2%9C%93" ) }
    it { should have_link('2') }
    it { should_not have_link('3') }
    #it { should_not have_link('3', href: "/?commit=Search&amp;direction=&amp;page=3&amp;search=te&amp;sort=&amp;utf8=%E2%9C%93") }
  end
  
  describe 'search_pagination' do
    let(:submit) {"Search"}
    before do
      FactoryGirl.create(:user, username: "searchtest1")
      FactoryGirl.create(:user, username: "peter1")
      FactoryGirl.create(:user, username: "searchtest9")
      FactoryGirl.create(:user, username: "peter9")
      FactoryGirl.create(:user, username: "searchtest3")
      FactoryGirl.create(:user, username: "peter3")
      FactoryGirl.create(:user, username: "searchtest4")
      FactoryGirl.create(:user, username: "peter4")
      FactoryGirl.create(:user, username: "searchtest5")
      FactoryGirl.create(:user, username: "peter5")
      FactoryGirl.create(:user, username: "searchtest6")
      FactoryGirl.create(:user, username: "peter6")
      visit users_path
      fill_in 'search', with:'searchtest4'
      click_button submit
    end
    after(:all)  { User.delete_all }
    it { should have_content("1 user") }
    it { should_not have_link('2', href: "/?commit=Search&direction=&page=2&search=searchtest4&sort=&utf8=✓" ) } 
  end
  
  describe 'search' do
    let(:submit) {"Search"}
    
    before do
      FactoryGirl.create(:user, username: "searchtest")
      visit users_path
      fill_in 'search', with:'searchtest'
      click_button submit
    end

    it 'should return results' do
      should have_content('searchtest')
      should have_content('1 user')
      
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