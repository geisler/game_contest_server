require 'spec_helper'

describe 'TournamentsPages' do
  let (:creator) { FactoryGirl.create(:contest_creator) }
  let!(:referee) { FactoryGirl.create(:referee) }
  let (:contest) { FactoryGirl.create(:contest, user: creator) }

  let (:name) { 'Test Tournament' }
  # Status shouldn't be in the form
  # let (:status) { 'waiting' }
  let (:now) { Time.current }
  let (:tournament_type) { 'round robin' }

  subject { page }

  describe 'create' do
    let(:submit) {'Create Tournament'}

    before do
      login creator
      visit new_contest_tournament_path(contest)
    end

    describe 'invalid information' do
      describe 'missing information' do
        it 'should not create a contest' do
          expect { click_button submit }.not_to change(Tournament, :count)
        end

        describe "after submission" do
          before { click_button submit }

          it { should have_alert(:danger) }
        end
      end # missing info

      illegal_dates = [{month: 'Feb', day: '30'},
        {month: 'Feb', day: '31'},
        {year: '2015', month: 'Feb', day: '29'},
        {month: 'Apr', day: '31'},
        {month: 'Jun', day: '31'},
        {month: 'Sep', day: '31'},
        {month: 'Nov', day: '31'}]
      illegal_dates.each do |date|
        describe "illegal date (#{date.to_s})" do
          before do
            fill_in 'Name', with: name
            select_illegal_datetime('Start', date)
            select 'Round Robin', from: 'Tournament type'
            click_button submit
          end

          it { should have_alert(:danger) }
        end
      end # illegal date

    end # invalid info

    describe 'valid information' do
      before do
        fill_in 'Name', with: name
        select_datetime(now, 'Start')
        select 'Round Robin', from: 'Tournament type'
      end

      it "should create a tournament" do
        expect { click_button submit }.to change(Tournament, :count).by(1)
      end

    end # valid info
  end # create
end
