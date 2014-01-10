#match_wrapper.rb
#Alex Sjoberg
#1/09/14
#

#Imports
require 'socket'

class MatchWrapper
    
    attr_accessor :result

    #Constructor, sets socket for communication to referee and starts referee and players
    def initialize(referee,*players)  
        #Sets port for referee to talk to wrapper_server  
        @wrapper_server = TCPServer.new(0)
        @players = players
        @referee = referee
        @child_list = []
    end

    def start_match

        #Start referee process, giving it the port to talk to us on
        wrapper_server_port = @wrapper_server.addr[1]
        @child_list.push(Process.spawn("ruby #{@referee} -p #{wrapper_server_port} &  > temp.txt  2>&1"))

        #Wait for referee to connect
        @ref_client = @wrapper_server.accept

        #Wait for referee to tell wrapper_server what port to start players on
        client_port = nil #TODO is there a better way to wait for this?
        while client_port.nil? #TODO error checking on returned port
            client_port = @ref_client.gets
        end

        #Start players
        @players.each do |player|
            @child_list.push(Process.spawn("ruby #{player} -p #{client_port}  > /dev/null"))
        end
        self.wait_for_result

    end

    def wait_for_result
        result = nil
        while result.nil?
            puts 'result is' , result
            result = @ref_client.gets
        end

        @result = result

        #Reaping Children!!!!!
        @child_list.each do |pid|
            Process.wait pid
        end
    end
end

=begin
match_wrapper = MatchWrapper.new("./test_referee.rb", "./test_player.rb", "./test_player.rb")
match_wrapper.start_match

puts match_wrapper.result
=end
