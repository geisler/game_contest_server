require 'spec_helper'

include ActionView::Helpers::DateHelper

describe "ContestsPages" do
  let (:creator) { FactoryGirl.create(:contest_creator) }
  let!(:referee) { FactoryGirl.create(:referee) }
  let (:now) { Time.current }
  let (:name) { 'Test Contest' }
  let (:description) { 'Contest description' }
  
  subject { page }
  
  describe "create" do
    let (:submit) { 'Create Contest' }
    
    before do
      login creator
      visit new_contest_path
    end
    
    describe "invalid information" do
      describe "missing information" do
        it "should not create a contest" do
          expect { click_button submit }.not_to change(Contest, :count)
        end
        
        describe "after submission" do
          before { click_button submit }
          
          it { should have_alert(:danger) }
        end
      end
      
      illegal_dates = [{month: 'Feb', day: '30'},
        {month: 'Feb', day: '31'},
        {year: '2018', month: 'Feb', day: '29'},
        {month: 'Apr', day: '31'},
        {month: 'Jun', day: '31'},
        {month: 'Sep', day: '31'},
        {month: 'Nov', day: '31'}]
      illegal_dates.each do |date|
        describe "illegal date (#{date.to_s})" do
          before do
            select_datetime(now, 'Deadline')
            fill_in 'Description', with: description
            fill_in 'Name', with: name
            select referee.name, from: 'Referee'
            click_button submit
          end
          
        end
      end
    end
    
    describe "valid information" do
      before do
        select_datetime(now, 'Deadline')
        fill_in 'Description', with: description
        fill_in 'Name', with: name
        select referee.name, from: 'Referee'
      end
      
      it "should create a contest" do
        expect { click_button submit }.to change(Contest, :count).by(1)
      end
      
      describe "redirects properly", type: :request do
        before do
          login creator, avoid_capybara: true
          post contests_path, contest: { deadline: now.strftime("%F %T"),
            description: description,
            name: name,
            referee_id: referee.id }
        end
        
        specify { expect(response).to redirect_to(contest_path(assigns(:contest))) }
      end
      
      describe "after submission" do
        let (:contest) { Contest.find_by(name: name) }
        
        before { click_button submit }
        
        specify { expect(contest.user).to eq(creator) }
        
        it { should have_alert(:success, text: 'Contest created') }
        it { should have_content(/less than a minute|1 minute/) }
        it { should have_content(description) }
        it { should have_content(name) }
        it { should have_content(contest.referee.name) }
        it { should have_link('New Player',
          href: new_contest_player_path(contest)) }
      end
    end
  end
  
  describe "edit" do
    let (:contest) { FactoryGirl.create(:contest, user: creator) }
    let!(:orig_name) { contest.name }
    let (:submit) { 'Update Contest' }
    
    before do
      login creator
      visit edit_contest_path(contest)
    end
    
    it { expect_datetime_select(contest.deadline, 'Deadline') }
    it { should have_field('Description', with: contest.description) }
    it { should have_field('Name', with: contest.name) }
    it { should have_select('Referee', selected: contest.referee.name) }
    
    describe "with invalid information" do
      before do
        select_datetime(now, 'Deadline')
        fill_in 'Name', with: ''
        fill_in 'Description', with: description
        select referee.name, from: 'Referee'
      end
      
      describe "does not change data" do
        before { click_button submit }
        
        specify { expect(contest.reload.name).not_to eq('') }
        specify { expect(contest.reload.name).to eq(orig_name) }
      end
      
      it "does not add a new contest to the system" do
        expect { click_button submit }.not_to change(Contest, :count)
      end
      
      it "produces an error message" do
        click_button submit
        should have_alert(:danger)
      end
    end
    
    describe "with valid information" do
      before do
        select_datetime(now, 'Deadline')
        fill_in 'Name', with: name
        fill_in 'Description', with: description
        select referee.name, from: 'Referee'
      end
      
      describe "changes the data" do
        before { click_button submit }
        
        it { should have_alert(:success) }
        specify { expect_same_minute(contest.reload.deadline, now) }
        specify { expect(contest.reload.name).to eq(name) }
        specify { expect(contest.reload.description).to eq(description) }
        specify { expect(contest.reload.referee.name).to eq(referee.name) }
        it { should have_link('New Player',
          href: new_contest_player_path(contest)) }
      end
      
      describe "redirects properly", type: :request do
        before do
          login creator, avoid_capybara: true
          patch contest_path(contest), contest: { deadline: now.strftime("%F %T"),
            description: description,
            name: name,
            referee_id: referee.id }
        end
        
        specify { expect(response).to redirect_to(contest_path(contest)) }
      end
      
      it "does not add a new contest to the system" do
        expect { click_button submit }.not_to change(Contest, :count)
      end
    end
  end
  
  describe "destroy", type: :request do
    let!(:contest) { FactoryGirl.create(:contest, user: creator) }
    
    before do
      login creator, avoid_capybara: true
    end
    
    describe "redirects properly" do
      before { delete contest_path(contest) }
      
      specify { expect(response).to redirect_to(contests_path) }
    end
    
    it "produces a delete message" do
      delete contest_path(contest)
      get response.location
      response.body.should have_alert(:success)
    end
    
    it "removes a contest from the system" do
      expect { delete contest_path(contest) }.to change(Contest, :count).by(-1)
    end
  end
  
  describe "pagination" do
    let (:contest) { FactoryGirl.create(:contest) }
    before do
    30.times { FactoryGirl.create(:contest) }
    
    visit contests_path
    end
    it { should have_content('10 contests') }
    it { should have_selector('div.pagination') }
    it { should have_link('2', href: "/contests?page=2" ) }
    it { should have_link('3', href: "/contests?page=3") }
    it { should_not have_link('4', href: "/contests?page=4") }
  end
  
  describe 'search_error'do
    let(:submit) {"Search"}
    before do
      FactoryGirl.create(:contest, name: "searchtest1")
      FactoryGirl.create(:contest, name: "peter1")
      
      visit contests_path
      fill_in 'search', with:':'
      click_button submit
    end
      after(:all)  { User.delete_all }
    it { should have_content("0 contests") }
    it { should_not have_link('2') }#, href: "/contests?utf8=✓&direction=&sort=&search=searchtest4&commit=Search" ) } 
    it {should have_alert(:info) }
  end
      
      
  
   describe 'search_parcial' do
    let(:submit) {"Search"}
    before do
      FactoryGirl.create(:contest, name: "searchtest1")
      FactoryGirl.create(:contest, name: "peter1")
      FactoryGirl.create(:contest, name: "searchtest2")
      FactoryGirl.create(:contest, name: "peter2")
      FactoryGirl.create(:contest, name: "searchtest9")
      FactoryGirl.create(:contest, name: "peter9")
      FactoryGirl.create(:contest, name: "searchtest4")
      FactoryGirl.create(:contest, name: "peter4")
      FactoryGirl.create(:contest, name: "searchtest5")
      FactoryGirl.create(:contest, name: "peter5")
      FactoryGirl.create(:contest, name: "searchtest6")
      FactoryGirl.create(:contest, name: "peter6")
      FactoryGirl.create(:contest, name: "searchtest7")
      FactoryGirl.create(:contest, name: "peter7")
      FactoryGirl.create(:contest, name: "searchtest8")
      FactoryGirl.create(:contest, name: "peter8")
      visit contests_path
      fill_in 'search', with:'te'
      click_button submit
    end
    after(:all)  { User.delete_all }
     it { should have_content("10 contests") }
    it { should have_link('2') }
    it { should_not have_link('3') }
   # it { should_not have_link('3', href: "/contests?utf8=✓&direction=&sort=&search=te&commit=Search") }
  end
  
  describe 'search_pagination' do
    let(:submit) {"Search"}
    before do
       FactoryGirl.create(:contest, name: "searchtest1")
      FactoryGirl.create(:contest, name: "peter1")
      FactoryGirl.create(:contest, name: "searchtest2")
      FactoryGirl.create(:contest, name: "peter2")
      FactoryGirl.create(:contest, name: "searchtest3")
      FactoryGirl.create(:contest, name: "peter3")
      FactoryGirl.create(:contest, name: "searchtest4")
      FactoryGirl.create(:contest, name: "peter4")
      FactoryGirl.create(:contest, name: "searchtest5")
      FactoryGirl.create(:contest, name: "peter5")
      FactoryGirl.create(:contest, name: "searchtest6")
      FactoryGirl.create(:contest, name: "peter6")
      visit contests_path
      fill_in 'search', with:'searchtest4'
      click_button submit
    end
    after(:all)  { User.delete_all }
    it { should have_content("1 contest") }
    it { should_not have_link('2') }#, href: "/contests?utf8=✓&direction=&sort=&search=searchtest4&commit=Search" ) } 
  end
  
  describe 'search' do
    let(:submit) {"Search"}
    
    before do
      FactoryGirl.create(:contest, name: "searchtest")
      visit contests_path
      fill_in 'search', with:'searchtest'
      click_button submit
    end

    it 'should return results' do
      should have_content('searchtest')
      should have_content('1 contest')
      
   end
   end
  
  
  
  
  describe "show" do
    let (:contest) { FactoryGirl.create(:contest) }
    
    before { visit contest_path(contest) }
    
    it { should have_content(contest.name) }
    it { should have_content(contest.description) }
    it { should have_content(distance_of_time_in_words_to_now(contest.deadline)) }
    it { should have_content(contest.user.username) }
    it { should have_link(contest.user.username, user_path(contest.user)) }
    it { should have_content(contest.referee.name) }
    it { should have_link(contest.referee.name, referee_path(contest.referee)) }
    # add Players that use this contest
    it { should have_link('New Player',
      href: new_contest_player_path(contest)) }
  end
  
  describe "show all" do
    before do
      5.times { FactoryGirl.create(:contest) }
      
      visit contests_path
    end
    
    it "lists all the contests in the system" do
      Contest.all.each do |c|
        should have_selector('li', text: c.name)
        should have_link(c.name, contest_path(c))
      end
    end
  end
end
