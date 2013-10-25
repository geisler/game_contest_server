require 'spec_helper'

describe "ContestManagerPages" do
  let (:creator) { FactoryGirl.create(:contest_creator) }

  subject { page }

  describe "create" do
    let!(:language) { FactoryGirl.create(:programming_language) }
    let (:submit) { 'Create Contest Manager' }

    before do
      login creator
      visit new_contest_manager_path
    end

    describe "missing information" do
      it "should not create a contest manager" do
	expect { click_button submit }.not_to change(ContestManager, :count)
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
		    Rails.root.join('spec', 'files', 'contest_manager.test'))
      end

      it "should create a contest manager" do
	expect { click_button submit }.to change(ContestManager, :count).by(1)
      end

      describe "after submission" do
	before { click_button submit }

	it { should have_alert(:success, text: 'Contest Manager created') }
      end
    end
  end
end
