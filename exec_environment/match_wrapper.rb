#! /usr/bin/env ruby

#match_wrapper.rbI
#Alex Sjoberg
#1/09/14


#TODO allow ref to specifiy a unique port for each player

#Imports
require 'socket'
require 'open-uri'
require 'timeout'
require 'active_support/time'

class MatchWrapper
    
    attr_accessor :results

    #Constructor, sets socket for communication to referee and starts referee and players
    def initialize(referee,number_of_players,max_match_time,*players)  
        #Sets port for referee to talk to wrapper_server  
        @wrapper_server = TCPServer.new(0)
        @players = players
        @referee = referee
        @child_list = []
        @number_of_players = number_of_players
        @max_match_time = max_match_time
        @results = {}
    end

    def start_match

        #Start referee process, giving it the port to talk to us on
        wrapper_server_port = @wrapper_server.addr[1]
        @ref_output = IO.pipe
        x = "temp.txt"
        @child_list.push(Process.spawn("#{@referee} -p #{wrapper_server_port} --num #{@number_of_players} & ", STDERR => x , STDOUT => x))

        #Wait for referee to connect
        @ref_client = @wrapper_server.accept

        #Wait for referee to tell wrapper_server what port to start players on
        begin
            Timeout::timeout(3) do
                @client_port = nil #TODO is there a better way to wait for this?
                while @client_port.nil? #TODO error checking on returned port
                    @client_port = @ref_client.gets
                end
            end
        rescue Timeout::Error
            puts 'Getting player port from referee failed!'
            exit 1
        end

        #Start players
        @players.each do |player|
            @child_list.push(Process.spawn("#{player.file_location}  --name #{player.name} -p #{@client_port} " , STDERR => player.output_location , STDOUT => player.output_location))
        end
        
        begin
            Timeout::timeout(10) do
                self.wait_for_result
            end
        rescue Timeout::Error
            puts 'Game exceeded allowed time!'
            exit 1
        end

    end

    def wait_for_result
        for i in 0...@number_of_players
            individual_result = nil
            while individual_result.nil?
                individual_result = @ref_client.gets
            end
            individual_result = individual_result.split("|")
            player_name = individual_result[0]
            match_result = individual_result[1]
            player_score = individual_result[2].to_i
            @results[player_name] = {'result' => match_result , 'score' => player_score}

        end


        #Reaping Children!!!!!
        @child_list.each do |pid|
            Process.wait pid
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


p1 = MockPlayer.new("dumb_player" , "./test_player.rb","p1_out.txt")
p2 = MockPlayer.new("stupid_player", "./test_player.rb", "p2_out.txt")
match_wrapper = MatchWrapper.new("./test_referee.rb", 2, 5, p1, p2)
match_wrapper.start_match

#puts match_wrapper.result
