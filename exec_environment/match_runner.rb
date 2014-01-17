#!/usr/bin/env ruby

require 'active_record'
require 'active_support/time'
require 'sqlite3'
require '/home/dbrown/game_contest_server_jterm/exec_environment/match_wrapper.rb'
#require './config/boot'
#require './config/environment'
require 'optparse'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: match_runner.rb -m [match_id]"

    opts.on('-m' , '--match_id [MATCH_ID]' , 'Match ID to start') { |v| $options[:MATCH_ID] = v}
    opts.on('-e' , '--useless [USELESS]' , '') { |v| $options[:USELESS] = v}

end.parse!
    
class MatchRunner
    
    def initialize(match_id)
       @match_id = match_id 
       @match = Match.find(match_id)
       @match_participants = @match.players
       @referee = @match.manager.contest.referee
       @number_of_players = @referee.players_per_game
       @max_match_time = 30.seconds
       @tournament = @match.manager
    end 
    
    #Uses a MatchWrapper to run a match between the given players and send the results to the database
    def run_match
        if @number_of_players != @match_participants.count()
            puts "   Match runner skipping match #"+@match_id.to_s+
                 "("+@match_participants.count().to_s+"/"+@number_of_players.to_s+" in player_matches)"
            return
        end
        match_wrapper = MatchWrapper.new(@referee,@number_of_players,@max_match_time,@match_participants)
        puts "   Match runner running match #"+@match_id.to_s
        match_wrapper.run_match
        self.send_results_to_db(match_wrapper.results)
    end

    #Creates PlayerMatch objects for each player using the results dictionary we got back from the MatchWrapper
    def send_results_to_db(results)
        puts "   Match runner writing results match #"+@match_id.to_s
        results.each do |player_name, player_result|
            player = Player.find_by_sql("SELECT * FROM Players WHERE contest_id = #{@tournament.contest.id} AND name = '#{player_name}'").first
            player_match = PlayerMatch.find_by_sql("SELECT * FROM Player_Matches WHERE match_id = #{@match.id} AND player_id = #{player.id}").first
            player_match.result = player_result["result"]
            player_match.score = player_result["score"]
            puts "    "+(player.name).ljust(24).slice(0,23)+
                 " Result: "+player_match.result.ljust(10).slice(0,9)+
                 " Score: "+player_match.score.to_s
            player_match.save!

        end
        puts "   Match runner finished match #"+@match_id.to_s
    end
end 

match_runner = MatchRunner.new($options[:MATCH_ID])
match_runner.run_match
