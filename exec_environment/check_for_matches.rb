#! /usr/bin/env ruby

require './config/boot'
require './config/environment'

match = Match.where("earliest_start < ? and status = ?", Time.now.utc, "waiting").first
if not match.nil? then
    puts "Running a match"
    match.status = "pending"
    match.save!
    Process.spawn("rails runner exec_environment/match_runner.rb -m #{match.id}")
    puts "Match succeeded"
end
