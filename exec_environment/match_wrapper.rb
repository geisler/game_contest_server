#! /usr/bin/env ruby

#match_wrapper.rbI
#Alex Sjoberg
#1/09/14


#TODO allow ref to specifiy a unique port for each player

#Imports
require 'socket'
require 'open-uri'

class MatchWrapper
    
    attr_accessor :result

    #Constructor, sets socket for communication to referee and starts referee and players
    def initialize(referee,number_of_players,*players)  
        #Sets port for referee to talk to wrapper_server  
        @wrapper_server = TCPServer.new(0)
        @players = players
        @referee = referee
        @child_list = []
        @number_of_players = number_of_players
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
        client_port = nil #TODO is there a better way to wait for this?
        while client_port.nil? #TODO error checking on returned port
            client_port = @ref_client.gets
        end

        #Start players
        @players.each do |player|
            @child_list.push(Process.spawn("#{player.file_location}  --name #{player.name} -p #{client_port} " , STDERR => player.output_location , STDOUT => player.output_location))
        end
        self.wait_for_result

    end

    def wait_for_result
        for i in 0...@number_of_players
            result = nil
            while result.nil?
                result = @ref_client.gets
                puts 'result is' , result
            end
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
match_wrapper = MatchWrapper.new("./test_referee.rb", 2  ,p1, p2)
match_wrapper.start_match

#puts match_wrapper.result
