#! /usr/bin/env ruby

#test_player.rb
#Alex Sjoberg
#1/8/2014
#

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

    def initialize()
      hostname = 'localhost'
      port = $options[:port]
      @ref_socket = TCPSocket.open(hostname,port)
      @name = $options[:name]
      @ref_socket.puts(@name)
    end

    #Connects to referee and guess random letter, closes when referee says wins
    def play
      response_options = ['a','b','c','w']
      while input = @ref_socket.gets
        #puts "Got input: "+input
        if input.include?('move')
          blah = response_options.sample
          @ref_socket.puts blah
          #puts "Sent "+blah
        elsif input.include?('wins')
          @ref_socket.close
          return
        end
      end
    end

end

p1 = TestPlayer.new
p1.play
