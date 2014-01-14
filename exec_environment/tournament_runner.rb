#!/usr/bin/env ruby

require 'active_record'
require 'active_support/time'
require 'sqlite3'
require '/home/asjoberg/game_contest_server_jterm/exec_environment/match_wrapper.rb'
require 'optparse'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: tournament.rb -c [tournament_id]"

    opts.on('-t' , '--tournament_id [CONTEST_ID]' , 'Tournament ID to start') { |v| $options[:TOURNAMENT_ID] = v}
    opts.on('-e' , '--useless [USELESS]' , '') { |v| $options[:USELESS] = v}

end.parse!


class TournamentRunner
    def initialize(tournament_id)
        @tournament_id = tournament_id
        @tournament = get_tournament
        @referee = get_referee
        @tournament_players = get_players
        @number_of_players = @referee.players_per_game
        @max_match_time = 30.seconds
    end

    def get_players
        #PlayerTournaments.find_by_sql("SELECT player_id FROM Player_Tournaments WHERE tournament_id = #{@tournament_id}")
       puts @tournament.players
    end

    def get_referee
        Tournament.find(@tournament_id).contest.referee
    end

    def get_tournament
        Tournament.find(@tournament_id)
    end

    def run_tournament
        round_robin
    end



    def round_robin
        @tournament_players.each do |player1|
            @tournament_players.each do |player2|
                if player1 != player2 then
                    
                    run_match(create_player_matches([player1, player2]), player1, player2)
                end
            end
        end
    end

    #Uses a MatchWrapper to run a match between the given players and send the results to the database
    def run_match(match, *match_participants)
        match = Match.create!(manager: @tournament , status: "Pending" , earliest_start: Time.now , completion: Date.new, match_type: MatchType.first, manager_type: "Contest" ,player_matches_attributes: create_player_matches(match_participants))
        match_wrapper = MatchWrapper.new(@referee,@number_of_players,@max_match_time,match_participants)
        match_wrapper.start_match
        self.send_results_to_db(match, match_wrapper.results)
    end

    def send_results_to_db(match, results)
        puts results
        results.each do |player_name, player_result|
            puts results
            player = Player.find_by_sql("SELECT * FROM Players WHERE contest_id = #{@tournament.contest.id} AND name = '#{player_name}'").first
            player_match = PlayerMatch.find_by_sql("SELECT * FROM Player_Matches WHERE match_id = #{match.id} AND player_id = #{player.id}").first
            player_match.result = player_result["result"]
            player_match.score = player_result["score"]
            player_match.save!
        end
    end

    def create_player_matches(match_participants)
        player_matches_list = []
        match_participants.each do |player|
            result = "Pending"
            score = nil
            player_matches_list.push({player: player, result: result, score: score})
        end
        return player_matches_list
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


puts "HI!!!!!!!!!!!!"
test_tournament = TournamentRunner.new($options[:TOURNAMENT_ID])
test_tournament.run_tournament
