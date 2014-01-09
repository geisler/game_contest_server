#! /bin/bash
ruby ./server.rb&
sleep .1
ruby ./client.rb -p 2000&
sleep .1
ruby ./client.rb -p 2000&
