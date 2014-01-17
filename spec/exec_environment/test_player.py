#! /usr/bin/env python

#test_player.py
#Douglas Brown
#1/15/2014
#

#imports
from optparse import OptionParser
import socket
from random import choice

#Parsing command line arguments
#Usage: client.py --name [name] -p [port]"
parser = OptionParser()
parser.add_option("-p","--port",action="store",type="int",dest="port")
parser.add_option("-n","--name",action="store",type="string",dest="name")
(options, args) = parser.parse_args()
#print "port"
#print options.port
#print "name"
#print options.name

HOST = 'localhost'
PORT = options.port
NAME = options.name



s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ip = socket.gethostbyname(HOST)
#print 'Ip address of ' + HOST + ' is ' + ip
s.connect((ip,PORT)) #Connect to server
#print 'Socket Connected to ' + HOST + ' on ip ' + ip

message = str(NAME)+"\n"
s.send(message)   

#Now receive data
while True:
    reply = s.recv(4096)
    #print "Got input: "+reply.strip()
    if "move" in reply:
        guesses = ['a','b','c','w']
        blah = choice(guesses)+"\n"
        s.send(blah)
        #print "Sent "+blah
    elif "wins" in reply:
        break





