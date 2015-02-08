require 'rails_helper'

#Check that creating a MatchWrapper works
describe "MatchWrapper" do
  before :each do
    @user = FactoryGirl.create(:user)
    @contest = FactoryGirl.create(:contest)
    @player1 = FactoryGirl.create(:player, user: @user, contest: @contest, name: 'dumb_player', file_location: Rails.root.join('spec', 'exec_environment', '../../examples/test_player.rb').to_s )
    @player2 = FactoryGirl.create(:player, user: @user, contest: @contest, name: 'stupid_player', file_location: Rails.root.join('spec', 'exec_environment', '../../examples/test_player.rb').to_s )
    @referee = FactoryGirl.create(:player, name: "referee", file_location: Rails.root.join('spec', 'exec_environment', '../../examples/test_referee.rb').to_s )
    @match_wrapper = MatchWrapper.new(@referee , 2, 5, [@player1, @player2], 1)
  end

  describe "create successful match" do
    it "should exist" do
      expect(@match_wrapper).to be_an_instance_of MatchWrapper
    end
    it "sucessful game should have results" do
      @match_wrapper.run_match
#      @match_wrapper.results.should have(2).string
      expect(@match_wrapper.results).to include("dumb_player")
      expect(@match_wrapper.results).to include("stupid_player")
    end
  end
end

describe "MatchWrapper" do
  before :each do
    @user = FactoryGirl.create(:user)
    @contest = FactoryGirl.create(:contest)
    @player1 = FactoryGirl.create(:player, user: @user, contest: @contest, name: 'dumb_player', file_location: Rails.root.join('spec', 'exec_environment', '../../examples/test_player.rb').to_s )
    @player2 = FactoryGirl.create(:player, user: @user, contest: @contest, name: 'stupid_player', file_location: Rails.root.join('spec', 'exec_environment', '../../examples/test_player.rb').to_s )
    @referee = FactoryGirl.create(:player, name: "referee", file_location: Rails.root.join('spec', 'exec_environment', '../files/dumb_referee.rb').to_s )
    @match_wrapper = MatchWrapper.new(@referee , 2, 5, [@player1, @player2], 1)
  end

  it "bad game, results should be inconclusive - referee timed out" do
    expect(@match_wrapper).to be_an_instance_of MatchWrapper
    @match_wrapper.run_match
    expect(@match_wrapper.results).to eql "INCONCLUSIVE: Referee failed to provide a port!"
  end
end

describe "MatchWrapper" do
  before :each do
    @user = FactoryGirl.create(:user)
    @contest = FactoryGirl.create(:contest)
    @player1 = FactoryGirl.create(:player, user: @user, contest: @contest, name: 'dumb_player', file_location: Rails.root.join('spec', 'exec_environment', '../files/dumb_player.rb').to_s )
    @player2 = FactoryGirl.create(:player, user: @user, contest: @contest, name: 'stupid_player', file_location: Rails.root.join('spec', 'exec_environment', '../files/dumb_player.rb').to_s )
    @referee = FactoryGirl.create(:player, name: "referee", file_location: Rails.root.join('spec', 'exec_environment', '../../examples/test_referee.rb').to_s )
    @match_wrapper = MatchWrapper.new(@referee , 2, 5, [@player1, @player2], 1)
  end

  it "bad game, results should be inconclusive - game exceeded allowed time" do
#    @match_wrapper.should be_an_instance_of MatchWrapper
    expect(@match_wrapper).to be_an_instance_of MatchWrapper
    @match_wrapper.run_match
#    @match_wrapper.results.should eql "INCONCLUSIVE: Game exceeded allowed time!"
    expect(@match_wrapper.results).to eql "INCONCLUSIVE: Game exceeded allowed time!"
  end
end

#Test timeout for final game results
