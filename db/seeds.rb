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

creator = User.create!(
    username: "Contest Creator", 
    email: "creator@test.com",
    password: "password",
    password_confirmation: "password",
    admin: true,
    contest_creator: true,
    chat_url: "www.google.com"
) 

student = User.create!(
    username: "Student",
    email: "student@test.com",
    password: "password",
    password_confirmation: "password",
    admin: false,
    contest_creator: false,
    chat_url: "www.google.com"
) 

referee = Referee.create!(
    user: creator,
    name: "Guess W!",
    rules_url: "http://www.google.com",
    players_per_game: 2,
    file_location: Rails.root.join("spec" , "exec_environment" , "test_referee.rb").to_s
)

contest = Contest.create!(
    user: creator,
    referee: referee,
    deadline: DateTime.now + 5.minutes,
    description: "test",
    name: "test_contest"
)

tournament = Tournament.create!(
    contest: contest,
    name: "Round Robin Test Tournament",
    start: Time.now + 30.seconds,
    tournament_type: "round robin",
    status: "waiting"
)

tournament2 = Tournament.create!(
    contest: contest,
    name: "Single Elimination Test Tournament",
    start: Time.now + 30.seconds,
    tournament_type: "single elimination",
    status: "waiting"
)

player1 = Player.create!(
    user: student,
    contest: contest,
    description: "test",
    name: "ruby_player",
    downloadable: false,
    playable: false,
    file_location: Rails.root.join("spec" , "exec_environment" , "test_player.rb").to_s
)
player2 = Player.create!(
    user: student,
    contest: contest,
    description: "test",
    name: "python_player",
    downloadable: false,
    playable: false,
    file_location: Rails.root.join("spec" , "exec_environment" , "test_player.py").to_s
)
player3 = Player.create!(
    user: student,
    contest: contest,
    description: "test",
    name: "idiot_player",
    downloadable: false,
    playable: false,
    file_location: Rails.root.join("spec" , "exec_environment" , "test_player.rb").to_s
)
player4 = Player.create!(
    user: student,
    contest: contest,
    description: "test",
    name: "smart_player",
    downloadable: false,
    playable: false,
    file_location: Rails.root.join("spec" , "exec_environment" , "test_player.rb").to_s
)

player1_tournament = PlayerTournament.create!(player: player1, tournament: tournament)
player2_tournament = PlayerTournament.create!(player: player2, tournament: tournament)
player3_tournament = PlayerTournament.create!(player: player3, tournament: tournament)

player1_tournament2 = PlayerTournament.create!(player: player1, tournament: tournament2)
player2_tournament2 = PlayerTournament.create!(player: player2, tournament: tournament2)
player3_tournament2 = PlayerTournament.create!(player: player3, tournament: tournament2)
player4_tournament2 = PlayerTournament.create!(player: player4, tournament: tournament2)

=begin
    This is a multi 
    line
    comment
=end

