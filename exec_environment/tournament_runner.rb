#!/usr/bin/env ruby

require 'active_record'
require 'active_support/time'
require 'sqlite3'
#require './config/boot'
#require './config/environment'
require 'optparse'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: tournament.rb -c [tournament_id]"

    opts.on('-t' , '--tournament_id [TOURNAMENT_ID]' , 'Tournament ID to start') { |v| $options[:TOURNAMENT_ID] = v}
    opts.on('-e' , '--useless [USELESS]' , '') { |v| $options[:USELESS] = v}

end.parse!


class TournamentRunner
    def initialize(tournament_id)
        @tournament_id = tournament_id
        @tournament = get_tournament 
        @referee = get_referee
        @tournament_players = get_players
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
        round_robin
    end


    #Runs a round robin tournament with each player playing every other player twice.
    #Currently only works with 2 player games
    def round_robin
        @tournament_players.each do |player1|
            @tournament_players.each do |player2|
                if player1 != player2 then
                    create_match(player1, player2)
                end
            end
        end
        #need to check matches completed
        #@tournament.status = "completed"
        #@tournament.save!
    end


    def create_match(*match_participants)
        puts @tournament
        match = Match.create!(manager: @tournament , status: "waiting" , earliest_start: Time.now , completion: Date.new, match_type: MatchType.first , player_matches_attributes: create_player_matches(match_participants))
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
