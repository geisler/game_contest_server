#! /bin/sh
# Game contest sever match listener

cd ../../home/jgeisler/game_contest_server
clockworkd -d . start ./clock.rb --log
