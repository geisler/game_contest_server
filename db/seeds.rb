# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
=begin
%w(C C++ Java Python Ruby).each do |lang|
  ProgrammingLanguage.create(name: lang)
end

creator = User.create!(username: "Contest Creator" , email: "creator@test.com" , password: "password" ,password_confirmation: "password", admin: true , contest_creator: true , chat_url: "www.google.com")

student = User.create!(username: "Student" , email: "student@test.com" , password: "password" ,password_confirmation: "password", admin: false , contest_creator: false , chat_url: "www.google.com")

referee = Referee.create!(user: creator , name: "Guess W!" , rules_url: "http://www.google.com" , players_per_game: 2 , file_location: Rails.root.join("spec" , "exec_environment" , "test_referee.rb").to_s)

contest = Contest.create!(user: creator , referee: referee , deadline: DateTime.now + 5.minutes , description: "test" , name: "test_contest" , contest_type: "single_elimination")

player = Player.create!( user: student , contest: contest , description: "test" , name: "dumb_player" , downloadable: false, playable: false , file_location: Rails.root.join("spec" , "exec_environment" , "test_player.rb").to_s)

player = Player.create!( user: student , contest: contest , description: "test" , name: "stupid_player" , downloadable: false, playable: false , file_location: Rails.root.join("spec" , "exec_environment" , "test_player.rb").to_s)
=end
