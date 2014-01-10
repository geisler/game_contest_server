#test_referee.rb
##Alex Sjoberg
#1/8/14

#Imports
require 'socket'
require 'optparse'

#This section contains the code to allow for command line arguements
$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: client.rb -p [port] --num [num]"

    opts.on('-p' , '--port [PORT]' , 'Port for client to connect to') { |v| $options[:port] = v}
    opts.on('-n' , '--num [NUM]' , 'Number of players we will pass the referee') { |v| $options[:num] = v.to_i}

end.parse!


class TestReferee
    #Intialize function that opens communication from referee to wrapper and selects port 
    #for referee to cleint communication
    def initialize 
        @players = []
        #@num_players = 2
        @num_players = $options[:num] 

        #Setting up connection from referee to  wrapper
        wrapper_hostname = 'localhost'
        wrapper_port = $options[:port]

        #Opens connection to referee to wrapper
        @wrapper_connection = TCPSocket.open(wrapper_hostname, wrapper_port)

        #Send port to wrapper for client communication iwht referee
        @ref_server = TCPServer.open(0)
        ref_port = @ref_server.addr[1]
        @wrapper_connection.puts(ref_port)
    end

    #Turn based game where first player to answer "w" wins
    def run_method
        for i in 0...@num_players do
            @players.push(@ref_server.accept)
        end

        loop do
            @players.each do |player|
                player.puts 'move'
                input = player.gets
                if check_win(input)
                    @players.each do |player_BAD|
                        player_BAD.puts('Player' , @players.index(player) , 'wins!' )
                        player_BAD.close
                    end
                    result = "Player #{@players.index(player)} wins!"
                    @wrapper_connection.puts(result)
                    return
                end
            end
        end
    end

    def check_win(input)
        input.include?('w')
    end
end

test_referee = TestReferee.new()
test_referee.run_method
