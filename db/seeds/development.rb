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
  file_location: Rails.root.join( "examples" , "test_referee.rb").to_s
)

contest = Contest.create!(
  user: creator,
  referee: referee,
  deadline: DateTime.now + 5.minutes,
  description: "test",
  name: "test_contest"
)

player1 = Player.create!(
  user: student,
  contest: contest,
  description: "test",
  name: "Phil",
  downloadable: false,
  playable: false,
  file_location: Rails.root.join( "examples" , "test_player.rb").to_s
)
player2 = Player.create!(
  user: student,
  contest: contest,
  description: "test",
  name: "Justin",
  downloadable: false,
  playable: false,
  file_location: Rails.root.join( "examples" , "test_player.py").to_s
)
player3 = Player.create!(
  user: student,
  contest: contest,
  description: "test",
  name: "Alex",
  downloadable: false,
  playable: false,
  file_location: Rails.root.join("examples" , "test_player.rb").to_s
)
player4 = Player.create!(
  user: student,
  contest: contest,
  description: "test",
  name: "Doug",
  downloadable: false,
  playable: false,
  file_location: Rails.root.join("examples" , "test_player.rb").to_s
)
player5 = Player.create!(
  user: student,
  contest: contest,
  description: "test",
  name: "David",
  downloadable: false,
  playable: false,
  file_location: Rails.root.join("examples"  , "test_player.py").to_s
)
player6 = Player.create!(
  user: student,
  contest: contest,
  description: "test",
  name: "Nathan",
  downloadable: false,
  playable: false,
  file_location: Rails.root.join("examples" , "test_player.py").to_s
)
player7 = Player.create!(
  user: student,
  contest: contest,
  description: "test",
  name: "Juan",
  downloadable: false,
  playable: false,
  file_location: Rails.root.join( "examples" , "test_player.rb").to_s
)

tournament = Tournament.create!(
  contest: contest,
  name: "Round Robin Test Tournament",
  start: Time.now + 10.seconds,
  tournament_type: "round robin",
  status: "waiting"
)
player1_tournament = PlayerTournament.create!(player: player1, tournament: tournament)
player2_tournament = PlayerTournament.create!(player: player2, tournament: tournament)
player3_tournament = PlayerTournament.create!(player: player3, tournament: tournament)

tournament2 = Tournament.create!(
  contest: contest,
  name: "Single Elimination Test Tournament",
  start: Time.now + 10.seconds,
  tournament_type: "single elimination",
  status: "waiting"
)
player1_tournament2 = PlayerTournament.create!(player: player1, tournament: tournament2)
player2_tournament2 = PlayerTournament.create!(player: player2, tournament: tournament2)
player3_tournament2 = PlayerTournament.create!(player: player3, tournament: tournament2)
player4_tournament2 = PlayerTournament.create!(player: player4, tournament: tournament2)
player5_tournament2 = PlayerTournament.create!(player: player5, tournament: tournament2)
player6_tournament2 = PlayerTournament.create!(player: player6, tournament: tournament2)
player7_tournament2 = PlayerTournament.create!(player: player7, tournament: tournament2)

