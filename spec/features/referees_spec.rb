require 'spec_helper'

describe "RefereePages" do
  let (:creator) { FactoryGirl.create(:contest_creator) }

  subject { page }

  describe "create" do
   pending do
    let!(:language) { FactoryGirl.create(:programming_language) }
    let (:submit) { 'Create Referee' }

    before do
      login creator
      visit new_referee_path
    end

    describe "missing information" do
      it "should not create a referee" do
	expect { click_button submit }.not_to change(Referee, :count)
      end

      describe "after submission" do
	before { click_button submit }

	it { should have_alert(:danger) }
      end
    end

    describe "valid information" do
      before do
	select language.name, from: 'Programming Language'
	attach_file('Upload file',
		    Rails.root.join('spec', 'files', 'referee.test'))
      end

      it "should create a referee" do
	expect { click_button submit }.to change(Referee, :count).by(1)
      end

      describe "after submission" do
	before { click_button submit }

	it { should have_alert(:success, text: 'Referee created') }
      end
    end
   end
  end
end
