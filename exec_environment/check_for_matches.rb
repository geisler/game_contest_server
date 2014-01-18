#! /usr/bin/env ruby
#Alex Sjoberg
#match_checker.rb
#Jan 2014
# Queries db for matches whose start date has passed and is "waiting" to be started
#
# TODO Queueing all available matches instead of just spawning one each time. Maybe using Delayed Job?

require './config/boot'
require './config/environment'

match = Match.where("earliest_start < ? and status = ?", Time.now.utc, "waiting").first
if not match.nil? then
    match.status = "started"
    match.save!
    puts "  Daemon spawning match #"+match.id.to_s
    Process.spawn("rails runner exec_environment/match_runner.rb -m #{match.id}")
end
