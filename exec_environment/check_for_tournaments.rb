#! /usr/bin/env ruby

require './config/boot'
require './config/environment'

tournament = Tournament.where("start < ? and status = ?", Time.now.utc, "waiting").first
if not tournament.nil? then
    tournament.status = "started"
    tournament.save
    puts "Daemon spawning tournament #"+tournament.id.to_s
    Process.spawn("rails runner exec_environment/tournament_runner.rb -t #{tournament.id}")
end
