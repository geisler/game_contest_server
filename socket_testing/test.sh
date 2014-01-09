#! /bin/bash
ruby ./server.rb&
sleep .1
ruby ./client.rb&
sleep .1
ruby ./client.rb&
