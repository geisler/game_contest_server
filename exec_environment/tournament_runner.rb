#!/usr/bin/env ruby

require 'active_record'
require 'active_support/time'
require 'sqlite3'
require '/home/asjoberg/game_contest_server_jterm/exec_environment/match_wrapper.rb'
#require './config/boot'
#require './config/environment'
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
       @tournament.players
    end

    def get_referee
        Tournament.find(@tournament_id).contest.referee
    end

    def get_tournament
        Tournament.find(@tournament_id)
    end

    #Runs a tournament
    def run_tournament
        @tournament.status = "pending"
        @tournament.save!
        round_robin
    end


    #Runs a round robin tournament with each player playing every other player twice.
    #Currently only works with 2 player games
    def round_robin
        @tournament_players.each do |player1|
            @tournament_players.each do |player2|
                if player1 != player2 then
                    run_match(player1, player2)
                end
            end
        end
        @tournament.status = "completed"
        @tournament.save!
    end

    #Uses a MatchWrapper to run a match between the given players and send the results to the database
    def run_match(*match_participants)
        match = Match.create!(manager: @tournament , status: "Pending" , earliest_start: Time.now , completion: Date.new, match_type: MatchType.first, manager_type: "Contest" ,player_matches_attributes: create_player_matches(match_participants))
        match_wrapper = MatchWrapper.new(@referee,@number_of_players,@max_match_time,match_participants)
        match_wrapper.run_match
        self.send_results_to_db(match, match_wrapper.results)
    end

    #Creates PlayerMatch objects for each player using the results dictionary we got back from the MatchWrapper
    def send_results_to_db(match, results)
        results.each do |player_name, player_result|
            player = Player.find_by_sql("SELECT * FROM Players WHERE contest_id = #{@tournament.contest.id} AND name = '#{player_name}'").first
            player_match = PlayerMatch.find_by_sql("SELECT * FROM Player_Matches WHERE match_id = #{match.id} AND player_id = #{player.id}").first
            player_match.result = player_result["result"]
            player_match.score = player_result["score"]
            player_match.save!
        end
    end

    #Returns a dictionary with the attributes necessary for a match to create stub PlayerMatches as it it being created.
    #The match needs to do this because of the interdependency betwene the two records. Neether can exist without the other
    #so they need to be created at the same time
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

#What gets run when the daemon starts up a new tournament
new_tournament = TournamentRunner.new($options[:TOURNAMENT_ID])
new_tournament.run_tournament
