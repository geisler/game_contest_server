#! /usr/bin/env ruby
#    ^
#    |
#    |
# NOTE don't forget the shebang in your ref and players!

# test_referee.rb
# Alex Sjoberg
# 1/8/14
#
# Example referee for a simple game in which the first player to input the letter 'w' wins.
# Showcases the basic functionality a referee needs to interact with our server

#Imports
require 'socket'
require 'optparse'

#This section contains the code to allow for command line arguments
$options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: client.rb -p [port] --num [num]"

  opts.on('-p' , '--port [PORT]' , 'Port for client to connect to') { |v| $options[:port] = v}
  opts.on('-n' , '--num [NUM]' , 'Number of players we will pass the referee') { |v| $options[:num] = v.to_i}

end.parse!


class TestReferee

  #Intialize function that opens communication from referee to wrapper and selects port
  #for referee to client communication
  def initialize
    @players = {}
    #@num_players = 2
    @num_players = $options[:num]

    #Setting up connection from referee to  wrapper
    wrapper_hostname = 'localhost'
    wrapper_port = $options[:port]

    #Opens connection from referee to wrapper
    @wrapper_connection = TCPSocket.open(wrapper_hostname, wrapper_port)

    #Send port to wrapper for player communication with referee
    @ref_server = TCPServer.open(0)
    ref_port = @ref_server.addr[1]
    @wrapper_connection.puts(ref_port)
  end


  #Listen for attempts to connect to our port. When a player connects, wait for them to send their name
  def accept_player_connection
    new_connection = @ref_server.accept

    #NOTE if players are taking a long time to respond here, other pending connections may time out
    new_player_name = nil
    while new_player_name.nil? do
      new_player_name = new_connection.gets
    end
    @players[new_player_name] = new_connection

  end

  #Report results of the game back to the wrapper as a single string of the form:
  #   [player_name]|[result]|[player_score]
  def report_results(winner_name)
    @players.each do |player_name, socket|
      if player_name == winner_name
        result = "Win"
      else
        result = "Loss"
      end
      score = rand(1...5) #meaningless
      result_string = player_name.strip + "|" + result + "|" + score.to_s
      @wrapper_connection.puts(result_string)
    end
    return
  end

  #If they input 'w' they win
  def check_win(input)
    input.include?('w')
  end


  #Turn based game where first player to answer "w" wins
  def run_game
    @num_players.times do
      accept_player_connection
    end

    loop do
      @players.each do |player_name,socket|
        socket.puts 'move'
        input = socket.gets
        if check_win(input)
          inform_players_of_win(player_name)
          report_results(player_name)
          @wrapper_connection.close
          return
        end
      end
    end
  end

  #Sends a notification to our players that the game is over
  def inform_players_of_win(winner_name)
    @players.each do |player_name,socket|
      socket.puts(winner_name + ' wins!' )
      socket.close
    end
  end
end

test_referee = TestReferee.new()
test_referee.run_game
