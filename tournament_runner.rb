#! /usr/bin/env ruby

require 'active_record'
require 'active_support/time'
require 'sqlite3'
require './match_wrapper.rb'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: tournament.rb -c [contest_id]"
  
  opts.on('-c' , '--contest_id [CONTEST_ID]' , 'Contest ID to start') { |v| $options[:CONTEST_ID] = v}

end.parse!

class Tournament 
    def initialize(contest_id)
        @contest_id = contest_id
        @referee = get_referee
        @max_match_time = 30.seconds

    end

    def run_tournament
        players = self.get_players
        start_match(players[0],players[1])
    end

    def get_players
        Player.find_by_sql("SELECT * FROM Players WHERE contest_id = #{@contest_id}")
    end

    def get_referee
        Contest.find(@contest_id).referee
    end

    def connect_to_db
        x = ActiveRecord::Base.establish_connection(
            :adapter => 'sqlite3',
            :database => '../db/development.sqlite3'
        )
    end

    def start_match(p1,p2)
       match = MatchWrapper.new(@referee,2,@max_match_time,p1,p2)
       match.start_match
       puts match.results
       self.send_results_to_db(match.results)
    end

    def run_single_elimination(players)
        if players.length == 1
            return players[0]
        elsif players.length == 2
            results = self.start_match(players[0],players[1])
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

    def send_results_to_db(results)
        results.each do |player_name, player_result|
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


test_tournament = Tournament.new(1)
test_tournament.run_tournament
