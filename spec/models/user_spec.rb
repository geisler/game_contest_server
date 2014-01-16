require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }
  subject { user }

  # Tables
  it { should respond_to(:contests) }
  it { should respond_to(:referees) }
  it { should respond_to(:players) }

  # Attributes
  it { should respond_to(:username) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }

  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should respond_to(:admin) }
  it { should respond_to(:contest_creator) }
  it { should respond_to(:banned) }

  it { should respond_to(:chat_url) }

  describe "validations" do
    it { should be_valid }
  end

  it { should_not be_admin }
  it { should_not be_contest_creator }
  it { should_not be_banned }


  # username tests #
  describe "empty username" do
    before { user.username = '' }
    it { should_not be_valid }
  end

  describe "blank username" do
    before { user.username = ' ' }
    it { should_not be_valid }
  end

  describe "long username" do
    before { user.username = 'z' * 25 }
    it { should be_valid }
  end

  describe "too long username" do
    before { user.username = 'z' * 26 }
    it { should_not be_valid }
  end

  describe "duplicate username" do
    let(:duplicate) { user.dup }
    it "is not allowed" do
      expect(duplicate).not_to be_valid
    end
  end


  # email tests #
  describe "empty email" do
    before { user.email = '' }
    it { should_not be_valid }
  end

  describe "blank email" do
    before { user.email = ' ' }
    it { should_not be_valid }
  end

  #
  # tests directly from Michael Hartl's Rails tutorial
  describe "various email formats" do
    describe "poorly formed addresses" do
      invalid_addresses = %w[user@foo,com
         user_at_foo.org
         example.user@foo.
         foo@bar_baz.com
         foo@bar+baz.com
      ]

      invalid_addresses.each do |invalid_address|
        it "is invalid" do
          user.email = invalid_address
          expect(user).not_to be_valid
        end
      end
    end

    describe "properly formed addresses" do
      valid_addresses = %w[user@foo.COM
         A_US-ER@f.b.org
         frst.lst@foo.jp
         a+b@baz.cn
      ]

      valid_addresses.each do |valid_address|
        it "is valid" do
          user.email = valid_address
          expect(user).to be_valid
        end
      end
    end
  end

  describe "duplicate email" do
    let(:duplicate) { user.dup }
    it "is allowed" do
      user.username = "Duplicate User"
      expect(duplicate).to be_valid
    end
  end

  describe "authentication" do
    let(:candidate_user) { User.find_by(username: user.username) }

    describe "with valid password" do
      it { should eq candidate_user.authenticate(user.password) }
    end

    describe "with invalid password" do
      let(:authenticated_user) { candidate_user.authenticate('invalid') }

      it { should_not eq authenticated_user }
      specify { expect(authenticated_user).to be_false }
    end
  end

  describe "admin capabilities" do
    let(:admin) { FactoryGirl.create(:admin) }

    specify { expect(admin).to be_admin }
  end

  describe "contest creator capabilities" do
    let(:contest_creator) { FactoryGirl.create(:contest_creator) }

    specify { expect(contest_creator).to be_contest_creator }
  end
end
