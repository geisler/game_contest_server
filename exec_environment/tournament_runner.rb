#!/usr/bin/env ruby

require 'active_record'
require 'active_support/time'
require 'sqlite3'
require '/home/asjoberg/game_contest_server_jterm/exec_environment/match_wrapper.rb'
require 'optparse'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: tournament.rb -c [contest_id]"

    opts.on('-c' , '--contest_id [CONTEST_ID]' , 'Contest ID to start') { |v| $options[:CONTEST_ID] = v}
    opts.on('-e' , '--useless [USELESS]' , '') { |v| $options[:USELESS] = v}

end.parse!


class Tournament 
    def initialize(contest_id)
        @contest_id = contest_id
        @contest = get_contest
        @referee = get_referee
        @number_of_players = @referee.players_per_game
        @max_match_time = 30.seconds
    end

    def get_players
        Player.find_by_sql("SELECT * FROM Players WHERE contest_id = #{@contest_id}")
    end

    def get_referee
        Contest.find(@contest_id).referee
    end

    def get_contest
        Contest.find(@contest_id)
    end

    def run_tournament
        players = self.get_players
        match = create_match(players)
        run_match(match, players)
    end


    #Creates a match object and puts it in the database
    def create_match(players)
            match = Match.create!(manager: @contest , status: "Pending" , earliest_start: Time.now , completion: Date.new, match_type: MatchType.first, manager_type: "Contest" ,player_matches_attributes: create_player_matches(players))
    end

    def create_player_matches(players)
        player_matches_list = []
        players.each do |player|
            result = "Pending"
            score = nil
            player_matches_list.push({player: player, result: result, score: score})
        end
        return player_matches_list
    end

    #Uses a MatchWrapper to run a match between the given players and send the results to the database
    def run_match(match, players)
        p1=players[0]
        p2=players[1]
        match_wrapper = MatchWrapper.new(@referee,@number_of_players,@max_match_time,p1,p2)
        match_wrapper.start_match
        self.send_results_to_db(match, match_wrapper.results)
    end

    def run_single_elimination(players)
        if players.length == 1
            return players[0]
        elsif players.length == 2
            results = self.run_match(players[0],players[1])
            #parse out winner
            #store in the databse
            #return winner
        else
            #return the player that won the match between run-elim on both halves
            half = player.length/2
            l1 = players[0..half]
            l2 = players[half..players.length]
            return #idontknowwhat
        end
    end 

    def send_results_to_db(match, results)
        puts "CALLING!!!!!!!!!!!!!!!!!!!"
        results.each do |player_name, player_result|
            puts "RUNNING!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            puts player_name
            puts
            player = Player.find_by_sql("SELECT * FROM Players WHERE contest_id = #{@contest_id} AND name = '#{player_name}'").first
            player_match = PlayerMatch.find_by_sql("SELECT * FROM Player_Matches WHERE match_id = #{match.id} AND player_id = #{player.id}").first
            player_match.result = player_result["result"]
            player_match.score = player_result["score"]
            player_match.save!
        end
    end
end

#A class meant to mock a 'player' object from the database for testing
class MockPlayer
    attr_accessor :name , :file_location, :output_location

    def initialize(name,file_location,output_location)
        @name = name
        @file_location = file_location
        @output_location = output_location
    end
end

class MockReferee
    attr_accessor :name , :file_location

    def initialize(name,file_location)
        @name = name
        @file_location = file_location
    end
end


test_tournament = Tournament.new($options[:CONTEST_ID])
test_tournament.run_tournament
player_matches = PlayerMatch.all
player_matches.each do |p|
    puts p.player.name
end

