require 'spec_helper'

feature "HomePage" do
  before { visit root_path }

  subject { page }

  describe "the navigation bar" do
    it { should have_selector('.navbar') }

# get this working!!!
#    within ".navbar" do
      it { should have_link('Game Contest Server', href: root_path) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Sign Up', href: signup_path) }
#    end
  end
end
