#! /usr/bin/env ruby

require 'active_record'
require 'active_support/time'
require 'sqlite3'
require_relative 'match_wrapper.rb'


class Tournament 
    def initialize(contest_id)
        @contest_id = contest_id
        @referee = get_referee
        @max_match_time = 30.seconds

    end

    def run_tournament
        players = self.get_players

    end

    def get_players
        p1 = MockPlayer.new("dumb_player" , "./test_player.rb","p1_out.txt")
        p2 = MockPlayer.new("stupid_player", "./test_player.rb", "p2_out.txt")
        p3 = MockPlayer.new("idiot_player", "./test_player.rb", "p2_out.txt")
        p4 = MockPlayer.new("smart_player", "./test_player.rb", "p2_out.txt")
        query_results = [p1, p2 ,p3 ,p4]
    end

    def get_referee
        r = MockReferee.new("guess_w_ref" , "./test_referee.rb")
    end

    def connect_to_db
        x = ActiveRecord::Base.establish_connection(
            :adapter => 'sqlite3',
            :database => '../db/development.sqlite3'
        )
    end

    def start_match(p1,p2)
       match = MatchWrapper.new(@referee.file_location,2,@max_match_time,p1,p2)
       match.start_match
       match.results
       puts match.results
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
    def
        run_single_elimination_match(players)
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
