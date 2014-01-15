# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
%w(C C++ Java Python Ruby).each do |lang|
  ProgrammingLanguage.create(name: lang)
end

%W(Challenge Tournament Friendly #{'King of the Hill'}).each do |type|
  MatchType.create(kind: type)
end

creator = User.create!(username: "Contest Creator" , email: "creator@test.com" , password: "password" ,password_confirmation: "password", admin: true , contest_creator: true , chat_url: "www.google.com") 

student = User.create!(username: "Student" , email: "student@test.com" , password: "password" ,password_confirmation: "password", admin: false , contest_creator: false , chat_url: "www.google.com") 

referee = Referee.create!(user: creator , name: "Guess W!" , rules_url: "http://www.google.com" , players_per_game: 2 , file_location: Rails.root.join("spec" , "exec_environment" , "test_referee.rb").to_s)

contest = Contest.create!(user: creator , referee: referee , deadline: DateTime.now + 5.minutes , description: "test" , name: "test_contest")

tournament = Tournament.create!(contest: contest, name: "Test Tournament", start: Time.now + 30.seconds, tournament_type: "round robin", status: "waiting")

player1 = Player.create!( user: student , contest: contest , description: "test" , name: "dumb_player" , downloadable: false, playable: false , file_location: Rails.root.join("spec" , "exec_environment" , "test_player.rb").to_s)

player2 = Player.create!( user: student , contest: contest , description: "test" , name: "stupid_player" , downloadable: false, playable: false , file_location: Rails.root.join("spec" , "exec_environment" , "test_player.rb").to_s)

player1_tournament = PlayerTournament.create!(player: player1, tournament: tournament)

player2_tournament = PlayerTournament.create!(player: player2, tournament: tournament)

=begin
def create_player_matches(match_participants)
    player_matches_list = []
    match_participants.each do |player|
        result = "Pending"
        score = nil
        player_matches_list.push({player: player, result: result, score: score})
    end
    return player_matches_list
end

match1 = Match.create!(manager: tournament , status: "Pending" , earliest_start: Time.now , completion: Date.new, match_type: MatchType.first, manager_type: "Contest" ,player_matches_attributes: create_player_matches([player1,player2])

=end
