#!/usr/bin/env ruby
# Alex Sjoberg
# tournament_runner.rb
# Jan 2014
#
# Takes a tournament from the db and creates the necessary matches for it

require 'active_record'
require 'active_support/time'
require 'sqlite3'
require 'optparse'

# Possible alternative to using rails runner to access rails environment
#require './config/boot'
#require './config/environment'


#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: tournament.rb -t [tournament_id]"

    opts.on('-t' , '--tournament_id [TOURNAMENT_ID]' , 'Tournament ID to start') { |v| $options[:TOURNAMENT_ID] = v}

    #See match_runner.py for why this line is necessary
    opts.on('-e' , '--useless [USELESS]' , '') { |v| $options[:USELESS] = v}

end.parse!


# Class to spawn match objects for a given tournament object retrieved from the db
class TournamentRunner

    #Get information from database
    def initialize(tournament_id)
        @tournament_id = tournament_id
        @tournament = Tournament.find(@tournament_id)
        @referee = @tournament.contest.referee
        @tournament_players = @tournament.players
        @number_of_players = @referee.players_per_game
        @max_match_time = 30.seconds
    end


    # Creates match objects for the given tournament
    # TODO Error checking that does more than output errors to the screen
    def run_tournament
        puts " Tournament runner started creating matches for tournament #"+@tournament_id.to_s+" ("+@tournament.tournament_type+")"
        #TODO This should probably be a validation instead of an error here
        if @tournament_players.count < 2
            puts " ERROR: Can't run tournament with fewer than two players"
            return
        end
        # Change status so daemon does't pick it up again
        @tournament.status = "started"
        @tournament.save!

        # Run different tournament types
        case @tournament.tournament_type
            when "round robin"
                round_robin(@tournament_players)
            when "single elimination"
                if @number_of_players > 2
                    puts " ERROR: Single elimination doesn't work with more than 2 players per game"
                else
                    single_elimination(@tournament_players)
                end
                return
            else
                puts " ERROR: Tournament type is not recognized"
                return
        end
        puts " Tournament runner finished creating matches for tournament #"+@tournament_id.to_s
    end

    #Runs a round robin tournament with each player playing every other player twice.
    #Currently only works with 2 player games #TODO make it work with more than 2 players
    def round_robin(players)
        players.each do |player1|
            players.each do |player2|
                if player1 != player2 then
                    create_match(player1, player2)
                end
            end
        end
        #TODO need a way to check that all the matches are completed and set the tournament to completed in the db
        #@tournament.status = "completed"
        #@tournament.save!
    end
    
    #Runs a single elimination tournament (two players per match)
    def single_elimination(players)
        count = players.count
        #puts " This many players: "+count.to_s
        if count == 2
            return create_match(players[0],players[1])
        elsif count == 3
            child = create_raw_match("unassigned")
            create_player_matches(child,[players[0]])
            create_match_path("Win",child,create_match(players[1],players[2]))
            return child
        else
            child = create_raw_match("unassigned")
            half = count/2
            create_match_path("Win",child,single_elimination(players[0..half-1]))
            create_match_path("Win",child,single_elimination(players[half..count]))            
            return child
        end        
    end
    
    #Creates a match and the associated player_matches
    def create_match(*match_participants)
        match = create_raw_match("unassigned")
        create_player_matches(match,match_participants)
        match.status = "waiting"
        match.save!
        return match
    end 
    #Creates a match
    def create_raw_match(status = "waiting")
        match = Match.create!(
            manager: @tournament, 
            status: status,
            earliest_start: Time.now, 
            completion: Date.new,
        )
        puts " Tournament runner created match #"+match.id.to_s
        return match
    end 
    #Creates player matches
    def create_player_matches(match,match_participants)
        match_participants.each do |player|
            PlayerMatch.create!(
                match: match,
                player: player,
                result: "Pending",
                score: nil,
            )
            puts "   Added "+player.name
        end
    end
    #Creates match paths to a given child on a certain condition (like "Win") from a parent match
    def create_match_path(result,child,parent)
        MatchPath.create!(
            parent_match: parent,
            child_match: child,
            result: result
        )
        puts "   Added path (on "+result+") from match #"+parent.id.to_s+" to match #"+child.id.to_s
    end

end

#What gets run when the daemon starts up a new tournament
new_tournament = TournamentRunner.new($options[:TOURNAMENT_ID])
new_tournament.run_tournament
