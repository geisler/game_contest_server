require 'socket'


def main
  players = []
  num_players = 2
  
  server = TCPServer.open(2000)
  
  for i in 0...num_players do
    players.push(server.accept)
  end

  loop do
    players.each do |player|
      #puts player
      player.puts 'move'
      input = player.gets
      if check_win(input)
        players.each do |player_BAD|
          player_BAD.puts('Player' , players.index(player) , 'wins!' )
          puts player_BAD
          #players.delete(player_BAD)
          player_BAD.close
        end
        puts('Player' , players.index(player) , 'wins!' )
        return
      end
    end
  end
end
  
def check_win(input)
  input.include?('w')
end
  
main