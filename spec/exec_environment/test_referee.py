#! /usr/bin/env python

#test_player.py
#Douglas Brown
#1/15/2014
#

#imports
from optparse import OptionParser
import socket
import sys

#Parsing command line arguments
#Usage: client.py -p [port] --num [num]"
parser = OptionParser()
parser.add_option("-p","--port",action="store",type="int",dest="port")
parser.add_option("-n","--num",action="store",type="int",dest="num")
(options, args) = parser.parse_args()
#print "port"
#print options.port
#print "num"
#print options.num


HOST = ''   # Symbolic name meaning all available interfaces
PORT = options.port 
NUM = options.num




def run():
    #Connect to players
    for i in range(NUM):
        conn, addr = s.accept()
        connections.append(conn)
        addresses.append(addr)
        #print 'Connected with ' + addresses[i][0] + ':' + str(addresses[i][1])
        name = conn.recv(1024)
        names.append(name.strip())
        #print "Player "+str(i)+" is named "+name
        
    #print "Running game"
    run_game()
    #End Game
    #print "Game over"
    for i in range(NUM):
        connections[i].close()
        #print 'Closed connection ' + addresses[i][0] + ':' + str(addresses[i][1])    
    s.close()

def run_game():
    while 1:
        for i in range(NUM):
            if move(connections[i],i):
                return

def move(conn,playernum):
    #print names[playernum]+"'s turn"
    conn.send('move\n') 
    while True:
        reply = conn.recv(1024).strip()
        if reply != "":
            break
    #print names[playernum]+" guessed "+reply
    if check_win(reply):
        inform_players_of_win(playernum)
        #report_results(player_name)
        return True
    else:
        return False
        
def check_win(reply):
    return reply == 'w'
    
def inform_players_of_win(playernum):
    #print names[playernum]+" wins!"
    for i in range(NUM):
        connections[i].send(names[playernum]+" wins!\n")



s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(10)
#print 'Socket now listening'

connections = []
addresses = []
names = []
run()
