#! /usr/bin/env python3

#ref_helper.py
#Alex Sjoberg
#Jan 2014

from optparse import OptionParser
import socket

class PlayerConnection():

    def __init__(connection , address, player_name):
        #Get a connection from a player
        self.connection = connection
        self.address = address
        self.name = player_name
        pass

    def automatedMove():
        #send move to player over port
        pass


#To be run on import

#Parsing command line arguments
#Recieves port and number of players from game contest server
parser = OptionParser()
parser.add_option("-p","--port",action="store",type="int",dest="port")
parser.add_option("-n","--num",action="store",type="int",dest="num") #number of players, not used with checkers
(options, args) = parser.parse_args()

wrapper_port = options.port 
wrapper_hostname = 'localhost'


#connect to match wrapper
wrapper_socket = socket.socket(socket.AF_INET , socket.SOCK_STREAM)
wrapper_ip = socket.gethostbyname(wrapper_hostname)
wrapper_socket.connect((wrapper_ip , wrapper_port))


#create and bind socket to listen for connecting players
player_socket  = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
player_socket.bind(('',0))
player_socket_port = player_socket.getsockname()[1]

#Tell ref what port we want players to connect on
message = str(player_socket_port) + "\n" #need to add newline for wrapper to receive properly
wrapper_socket.send(message.encode()) 

#Wait for two players to connect and send their names
#TODO make this a function probably
print ("waiting to accept first connection")
conn1 , addr1 = wrapper_socket.accept()
P1_name = ""
while P1_name == "":
    conn1.recv(1024).strip()
P1 = PlayerConnection(conn1,addr1,P1_name)

print ("waiting to accept second connection")
conn2 , addr2 = wrapper_socket.accept()
P2_name = ""
while P2_name == "":
    conn2.recv(1024).strip()
P2 = PlayerConnection(conn2,addr1,P2_name)

#P1 and P2 can now be used as though they were players in the normal ref code



