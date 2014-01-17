#! /usr/bin/env python

#ref_helper.py
#Alex Sjoberg
#Jan 2014

from optparse import OptionParser
import socket

if __name__ == "__main__":

    #Parsing command line arguments
    #Recieves port and number of players from game contest server
    parser = OptionParser()
    parser.add_option("-p","--port",action="store",type="int",dest="port")
    parser.add_option("-n","--num",action="store",type="int",dest="num") #number of players, not used with checkers
    (options, args) = parser.parse_args()

    wrapper_port = options.port 
    wrapper_hostname = 'localhost'



    #create and bind socket
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(('',0))
    s.listen(10)



class PlayerConnection():

    def __init__():
        #Get a connection from a player
        pass

    def automatedMove():
        #send move to player over port
        pass

