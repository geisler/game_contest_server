require 'socket'

def main
  hostname = 'localhost'
  port = 2000
  response_options = ['a' , 'b' ,'c', 'w']
  
  socket = TCPSocket.open(hostname,port)
  
  while input = socket.gets
    if input.include?('move')
      socket.puts response_options.sample
    elsif input.include?('wins')
      puts 'its time to close now'
      socket.close
      return
    end
  end
end

main