#! /usr/bin/env python

#checkers_helper.py
#Alex Sjoberg
#Jan 2014
# Libary for COS 120 student checker program
#When started, sends name to port provided


#TODO need to be able to have access to students code in order to call their functrion
# could do this though passing the file location in as command line argument via match wrapper
# or just having student copy and paste this code into their file

import checkers_player


#imports
from optparse import OptionParser
import socket
from random import choice

#Parsing command line arguments
#Usage: client.py --name [name] -p [port]"
parser = OptionParser()
parser.add_option("-p","--port",action="store",type="int",dest="port")
parser.add_option("-n","--name" ,action="store",type="string",dest="name")

(options, args) = parser.parse_args()

#To be run on import

ref_hostname = 'localhost'
ref_port = options.port
player_name  = options.name

ref_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ref_ip = socket.gethostbyname(referee_hostname)
ref_socket.connect((ref_ip,ref_port))


while True;
    ref_message = ref_socket.recv(4096)
    reply = reply.split("|")
    


