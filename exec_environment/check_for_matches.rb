#! /usr/bin/env ruby

require './config/boot'
require './config/environment'

match = Match.where("earliest_start < ? and status = ?", Time.now.utc, "waiting").first
if not match.nil? then

    
    match.status = "pending"
    match.save!
    puts "  Daemon spawning match #"+match.id.to_s
    Process.spawn("rails runner exec_environment/match_runner.rb -m #{match.id}")
end
