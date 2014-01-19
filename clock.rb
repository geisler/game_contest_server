#! /usr/bin/env ruby
#
#Contains the jobs that the clockwork daemon will run at the set intervals.
#TODO add some sort of queueing logic, maybe using Delayed Job, to wait for a spawned match to finish before spawning the next one. May take place here or in check_for_matches. not sure

require 'clockwork'
module Clockwork

  handler do |job|
    Process.spawn(job)
  end

  #Every 10 seconds check the databse for tournaments that are waiting to be run
  every(10.seconds, 'exec_environment/check_for_tournaments.rb')
  #and check for matches that need to be run
  every(10.seconds, 'exec_environment/check_for_matches.rb')

end
