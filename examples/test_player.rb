#! /usr/bin/env ruby

# test_player.rb
# Alex Sjoberg
# 1/8/2014
#
# Player for "Guess W!" as hosted by test_referee.rb. First person to input 'w' wins!
# Provides an example for what a player needs to do to interract with match_wrapper and a referee

#imports
require 'socket'
require 'optparse'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: client.rb --name [name] -p [port]"

  opts.on('-p' , '--port [PORT]' , 'Port for client to connect to') { |v| $options[:port] = v}
  opts.on('-n' , '--name [NAME]' , 'Name the ref will use to identify the player') { |v| $options[:name] = v}

end.parse!

class TestPlayer

  # Sends name to referee on given port
  def initialize()
    hostname = 'localhost'
    port = $options[:port]
    @ref_socket = TCPSocket.open(hostname,port)
    @name = $options[:name]
    @ref_socket.puts(@name)
  end

  #Game logic for "Guess W!" Sends random letter when referee says 'move' Closes when ref says 'wins'
  def play
    response_options = ['a','b','c','w']
    while input = @ref_socket.gets
      if input.include?('move')
        blah = response_options.sample
        @ref_socket.puts blah
      elsif input.include?('wins')
        @ref_socket.close
        return
      end
    end
  end

end

#To be run when match_wrapper starts the player. Remember, players must be executable!
p1 = TestPlayer.new
p1.play
