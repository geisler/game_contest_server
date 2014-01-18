#! /usr/bin/env ruby
#Alex Sjoberg
#check_for_tournaments.rb
#Jan 2014
#
# Checks the db for tournaments whose start time has passed and are "waiting" to be started
# Tournament runner will then create necessary Match objects in the db

require './config/boot'
require './config/environment'

tournament = Tournament.where("start < ? and status = ?", Time.now.utc, "waiting").first
if not tournament.nil? then
    tournament.status = "started"
    tournament.save
    puts "Daemon spawning tournament #"+tournament.id.to_s
    Process.spawn("rails runner exec_environment/tournament_runner.rb -t #{tournament.id}")
end
