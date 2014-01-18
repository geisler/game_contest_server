#!/usr/bin/env ruby
#
#Alex Sjoberg
#match_runner.rb
#Jan 2014
#
#Takes a match_id and 

require 'active_record'
require 'active_support/time'
require 'sqlite3'
require '/home/asjoberg/game_contest_server_jterm/exec_environment/match_wrapper.rb' #NOTE this is hardcoded to be using the match_wrapper in asjoberg's directory right now
require 'optparse'

#This may be an alternative to running the file using 'rails runner'. These provide access to the rails environment
#require './config/boot'
#require './config/environment'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: match_runner.rb -m [match_id]"

    opts.on('-m' , '--match_id [MATCH_ID]' , 'Match ID to start') { |v| $options[:MATCH_ID] = v}

    # This is to allow specifying a rails environment when using 'rails runner'
    # A command of the form "rails runner -e test match_runner.rb -m 5" will make optionparser complain that it doesn't know what the -e flag is unless we accept it here.
    opts.on('-e' , '--useless [USELESS]' , '') { |v| $options[:USELESS] = v} 

end.parse!
    
class MatchRunner
    
    #Get necessary info from the database
    def initialize(match_id)
       @match_id = match_id 
       @match = Match.find(match_id)
       @match_participants = @match.players
       @referee = @match.manager.contest.referee
       @number_of_players = @referee.players_per_game
       @max_match_time = 8.seconds
       @tournament = @match.manager
    end 
    
    #Uses a MatchWrapper to run a match between the given players and send the results to the database
    def run_match
        if @number_of_players != @match_participants.count()
            puts "   Match runner skipping match #"+@match_id.to_s+
                 " ("+@match_participants.count().to_s+"/"+@number_of_players.to_s+" in player_matches)"
            return
        end
        match_wrapper = MatchWrapper.new(@referee,@number_of_players,@max_match_time,@match_participants)
        puts "   Match runner running match #"+@match_id.to_s
        match_wrapper.run_match
        self.send_results_to_db(match_wrapper.results)
    end

    #Creates PlayerMatch objects for each player using the results dictionary we got back from the MatchWrapper
    def send_results_to_db(results)
        if results.include? "INCONCLUSIVE"
            #Error handling, save "inconclusive" as match status
            puts "   "+results
            @match_participants.each do |player|
                player_match = PlayerMatch.find_by_sql("SELECT * FROM Player_Matches WHERE match_id = #{@match_id} AND player_id = #{player.id}").first
                player_match.result = "Error"
                player_match.save!        
                print_results(player.name,"Error",nil,"\n")                
            end
            puts "   Match runner could not finish match #"+@match_id.to_s
            return
        else
            #Print and save results, schedule follow-up matches
            child_matches = MatchPath.find_by_sql("SELECT result,child_match_id FROM match_paths WHERE match_paths.parent_match_id = #{@match_id}") 
            puts "   Match runner writing results match #"+@match_id.to_s
            results.each do |player_name, player_result|
                #Print and save
                player = Player.find_by_sql("SELECT * FROM Players WHERE contest_id = #{@tournament.contest.id} AND name = '#{player_name}'").first
                player_match = PlayerMatch.find_by_sql("SELECT * FROM Player_Matches WHERE match_id = #{@match_id} AND player_id = #{player.id}").first
                player_match.result = player_result["result"]
                player_match.score = player_result["score"]
                player_match.save!        
                print_results(player.name,player_match.result,player_match.score)
                #Follow up matches
                child_matches.each do |data|
                    if data.result == player_match.result
                        create_player_match(Match.find(data.child_match_id),player)
                    end
                end
                print "\n"
            end
            puts "   Match runner finished match #"+@match_id.to_s
        end

    end
    
    #Prints a name, result, and score
    def print_results(name,result,score,separator="")    
        print "    "+name.ljust(24).slice(0,23)+
         " Result: "+result.ljust(10).slice(0,9)+
         " Score: "+score.to_s.ljust(10).slice(0,9)+
         separator
    end
    
    #Creates player_match and updates the match status to waiting if necessary 
    def create_player_match(match,player)
        #Create player_match
        PlayerMatch.create!(
            match: match,
            player: player,
            result: "Pending",
            score: nil,
        )
        print "=> Match #"+match.id.to_s
        #Change status of match if necessary
        if match.players.count == @number_of_players
            match.status = "waiting"
        end
        match.save!
    end
end 

match_runner = MatchRunner.new($options[:MATCH_ID])
match_runner.run_match
