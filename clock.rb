#! /usr/bin/env ruby

require 'clockwork'
module Clockwork

    handler do |job|
        Process.spawn('pwd')
        Process.spawn(job)
    end

    every(10.seconds, 'exec_environment/check_for_tournaments.rb')

end
