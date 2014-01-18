#! /usr/bin/env python3

#ref_helper.py
#Alex Sjoberg
#Jan 2014

from optparse import OptionParser
import socket
import pickle

class PlayerConnection():

    def __init__(self, connection , address, player_name):
        #Get a connection from a player
        self.connection = connection
        self.address = address
        self.name = player_name

    def automatedMove(self, CB,player):
        self.connection.send(pickle.dumps((CB,player)))
        return pickle.loads(self.connection.recv(4096))


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
wrapper_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
wrapper_ip = socket.gethostbyname(wrapper_hostname)
wrapper_socket.connect((wrapper_ip , wrapper_port))


#create and bind socket to listen for connecting players
player_socket  = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
player_socket.bind(('',0))
player_socket_port = player_socket.getsockname()[1]
player_socket.listen(10)

#Tell ref what port we want players to connect on
message = str(player_socket_port) + "\n" #need to add newline for wrapper to receive properly
wrapper_socket.send(message.encode()) 

#Wait for two players to connect and send their names
#TODO make this a function probably

conn1,addr1 = player_socket.accept()
P1_name = ""
while P1_name == "":
    P1_name = conn1.recv(1024).decode()
P1 = PlayerConnection(conn1,addr1,P1_name)

conn2,addr2 = player_socket.accept()
P2_name = ""
while P2_name == "":
    P2_name = conn2.recv(1024).decode()
P2 = PlayerConnection(conn2,addr1,P2_name)


def report_results(p1wins,p2wins):
    p1result = "Win"
    p2result = "Loss"
    if p2wins >= p1wins:
        if p2wins != p1wins:
            p1result = "Loss"
            p2result = "Win"
        else:
            p1result = "Tie"
            p2result = "Tie"
    result_string = P1_name + "|" + p1result + "|" + str(p1wins)
    wrapper_socket.send((result_string+"\n").encode())
    result_string = P2_name + "|" + p2result + "|" + str(p2wins)
    wrapper_socket.send((result_string+"\n").encode())

