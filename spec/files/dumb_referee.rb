#! /usr/bin/env ruby

require 'optparse'

#For testing a broken ref that never responds

#This section contains the code to allow for command line arguements
$options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: client.rb -p [port] --num [num]"

    opts.on('-p' , '--port [PORT]' , 'Port for client to connect to') { |v| $options[:port] = v}
    opts.on('-n' , '--num [NUM]' , 'Number of players we will pass the referee') { |v| $options[:num] = v.to_i}
end.parse!
