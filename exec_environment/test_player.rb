#test_player.rb
#Alex Sjoberg
#1/8/2013
#

#imports
require 'socket'
require 'optparse'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: client.rb -p [port]"
  
  opts.on('-p' , '--port [PORT]' , 'Port for client to connect to') { |v| $options[:port] = v}
end.parse!

#Connects to referee and guess random letter, closes when referee says wins
def play
  hostname = 'localhost'
  port = $options[:port]
  response_options = ['a' , 'b' ,'c', 'w']
  
  socket = TCPSocket.open(hostname,port)
  
  while input = socket.gets
    if input.include?('move')
      socket.puts response_options.sample
    elsif input.include?('wins')
      socket.close
      return
    end
  end
end

play
