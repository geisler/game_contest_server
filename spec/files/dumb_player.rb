#! /usr/bin/env ruby

require 'optparse'

#Parsing command line arguements
$options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: client.rb -p [port] --name [name]"
  
  opts.on('-p' , '--port [PORT]' , 'Port for client to connect to') { |v| $options[:port] = v}
  opts.on('-n' , '--name [NAME]' , 'Name the ref will use to identify the player') { |v| $options[:name] = v}

end.parse!
