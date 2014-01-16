
require 'spec_helper'


#Check that creating a MatchWrapper works
#
=begin
describe "TournamentRunner" do
    before :each do
        @user = FactoryGirl.create(:user)
        @contest = FactoryGirl.create(:contest)
        @player1 = FactoryGirl.create(:player, user: @user, contest: @contest, name: 'dumb_player', file_location: Rails.root.join('spec', 'exec_environment', 'test_player.rb').to_s )
        @player2 = FactoryGirl.create(:player, user: @user, contest: @contest, name: 'stupid_player', file_location: Rails.root.join('spec', 'exec_environment', 'test_player.rb').to_s )
        @referee = FactoryGirl.create(:player, name: "referee", file_location: Rails.root.join('spec', 'exec_environment', 'test_referee.rb').to_s )
        @match_wrapper = MatchWrapper.new(@referee , 2, 5, [@player1, @player2])
    end

    describe "run succesful tournament" do
        it "should exist" do
            @match_wrapper.should be_an_instance_of MatchWrapper 
        end
        it "sucessful game should have results" do
            @match_wrapper.start_match
            @match_wrapper.results.should have(2).string
            @match_wrapper.results.should include("dumb_player")
            @match_wrapper.results.should include("stupid_player")
        end
    end
end

=end

#Run tournament, should create matches and PlayerMatches
#
#

