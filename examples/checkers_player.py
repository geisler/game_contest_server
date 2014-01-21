#! /usr/bin/env python3

EMPTY=0
INCs=[-1,1]
VALID_RANGE=range(8)
DEBUG=False
VISIBLE=True
from copy import *
from math import *
import random

def getPossibles(CB,player):
    possibles={}
    if player=="black":
        playerTokens=[3,4]
        opponentTokens=[1,2]
        rowInc=-1
    else:
        playerTokens=[1,2]
        opponentTokens=[3,4]
        rowInc=1
    possibles["moves"]=findMoves(CB,player,playerTokens,opponentTokens,rowInc)  #puts moves right into possibles D      
    oldJumps=findJumps(CB,player,playerTokens,opponentTokens,rowInc)
    newJumps=expandJumps(CB,player,oldJumps,playerTokens,opponentTokens,rowInc)
    while newJumps != oldJumps:
        oldJumps=newJumps
        newJumps=expandJumps(CB,player,oldJumps,playerTokens,opponentTokens,rowInc)
    possibles["jumps"]=newJumps
    possibles["crownings"]=findCrownings(CB,player,possibles)
    possibles["blocks"]=findBlocks(CB,player,possibles)
    return possibles

def findBlocks(CB,player,possible):
    #only finds placement blocks
    if player=="black":
        player="red"
        playerTokens=[1,2]
        opponentTokens=[3,4]
        rowInc=1
    else:
        player="black"    
        playerTokens=[3,4]
        opponentTokens=[1,2]
        rowInc=-1
    #Find jumps for opposing player
    oldJumps=findJumps(CB,player,playerTokens,opponentTokens,rowInc)
    newJumps=expandJumps(CB,player,oldJumps,playerTokens,opponentTokens,rowInc)
    while newJumps != oldJumps:
        oldJumps=newJumps
        newJumps=expandJumps(CB,player,oldJumps,playerTokens,opponentTokens,rowInc)
    blocks=[]
    for move in possible["moves"]:
        for jump in newJumps:
            for index in range(3,len(jump),3):
                if jump[index:index+2]==move[3:5]:
                    if move not in blocks:
                        blocks.append(move)
    for myJump in possible["jumps"]:
        for myIndex in range(3,len(myJump),3):
            for jump in newJumps:
                for index in range(3,len(jump),3):
                    if jump[index:index+2]==myJump[myIndex:myIndex+2]:
                        if myJump not in blocks:
                            blocks.append(myJump)
    return blocks
        
def findCrownings(CB,player,possibles):
    crownings=[]
    empties=[]
    singleCheckerPositions=[]
    if player=="black":
        for col in range(1,8,2):
            if CB[0][col]==EMPTY:
                empties.append("A"+str(col))
        for row in range(8):
            for col in range(8):
                if CB[row][col]==3:
                    singleCheckerPositions.append(chr(row+65)+str(col))                
    else:
        for col in range(0,8,2):
            if CB[7][col]==EMPTY:
                empties.append("H"+str(col))
        for row in range(8):
            for col in range(8):
                if CB[row][col]==1:
                    singleCheckerPositions.append(chr(row+65)+str(col))
    if len(empties)!=0:
        for move in possibles["moves"]:
            if move[3:] in empties and move[0:2] in singleCheckerPositions:
                crownings.append(move)
        for jump in possibles["jumps"]:
            if jump[-2:]in empties and jump[0:2] in singleCheckerPositions:
                crownings.append(jump)
    return crownings

def findMoves(CB,player,playerTokens,opponentTokens,rowInc):
    moves=[]
    #process all board positions    
    for row in range(8):
        for col in range(8):
            if CB[row][col] in playerTokens:
                if CB[row][col] not in [2,4]: #not a king
                    for colInc in INCs:
                        toRow=row+rowInc
                        toCol=col+colInc
                        if toRow in VALID_RANGE and toCol in VALID_RANGE and CB[toRow][toCol]==EMPTY:
                                moves.append(chr(row+65)+str(col)+":"+chr(toRow+65)+str(toCol))
                else: #a king
                    for rInc in INCs:
                        for colInc in INCs:
                            toRow=row+rInc
                            toCol=col+colInc
                            if toRow in VALID_RANGE and toCol in VALID_RANGE and CB[toRow][toCol]==EMPTY:
                                    moves.append(chr(row+65)+str(col)+":"+chr(toRow+65)+str(toCol))
                       
    return moves

def findJumps(CB,player,playerTokens,opponentTokens,rowInc):
    jumps=[]
    for row in range(8):
        for col in range(8):
            if CB[row][col] in playerTokens: #if this is a player piece
                if CB[row][col] not in [2,4]: #not a king
                    for colInc in INCs: #-1 and 1
                        jump=chr(row+65)+str(col)+":"
                        jumprow=row+rowInc
                        jumpcol=col+colInc
                        torow=row+2*rowInc
                        tocol=col+2*colInc
                        if jumprow in VALID_RANGE and jumpcol in VALID_RANGE and torow in VALID_RANGE and tocol in VALID_RANGE \
                        and CB[jumprow][jumpcol] in opponentTokens and CB[torow][tocol]==EMPTY:
                            jumps.append(jump+chr(torow+65)+str(tocol))
                else: #is a king
                    for colInc in INCs: #-1 and 1
                        for newRowInc in INCs:
                            jump=chr(row+65)+str(col)+":"
                            jumprow=row+newRowInc
                            jumpcol=col+colInc
                            torow=row+2*newRowInc
                            tocol=col+2*colInc
                            if jumprow in VALID_RANGE and jumpcol in VALID_RANGE and torow in VALID_RANGE and tocol in VALID_RANGE \
                            and CB[jumprow][jumpcol] in opponentTokens and CB[torow][tocol]==EMPTY:
                                jumps.append(jump+chr(torow+65)+str(tocol))
    return jumps

def expandJumps(CB,player,oldJumps,playerTokens,opponentTokens,rowInc):
    newJumps=[]
    for oldJump in oldJumps:
        row=ord(oldJump[-2])-65
        col=int(oldJump[-1])
        newJumps.append(oldJump)
        startRow=ord(oldJump[0])-65
        startCol=int(oldJump[1])
        if CB[startRow][startCol] not in [2,4]: #not a king
            for colInc in INCs:
                jumprow=row+rowInc
                jumpcol=col+colInc
                torow=row+2*rowInc
                tocol=col+2*colInc
                if jumprow in VALID_RANGE and jumpcol in VALID_RANGE and torow in VALID_RANGE and tocol in VALID_RANGE \
                and CB[jumprow][jumpcol] in opponentTokens and CB[torow][tocol]==EMPTY:
                    newJumps.append(oldJump+":"+chr(torow+65)+str(tocol))
                    if oldJump in newJumps:
                        newJumps.remove(oldJump)
        else: #is a king
            for colInc in INCs:
                for newRowInc in INCs:
                    jumprow=row+newRowInc
                    jumpcol=col+colInc
                    torow=row+2*newRowInc
                    tocol=col+2*colInc
                    if jumprow in VALID_RANGE and jumpcol in VALID_RANGE and torow in VALID_RANGE and tocol in VALID_RANGE \
                    and CB[jumprow][jumpcol] in opponentTokens and (CB[torow][tocol]==EMPTY or oldJump[0:2]==chr(torow+65)+str(tocol)) \
                    and ((oldJump[-2:]+":"+chr(torow+65)+str(tocol)) not in oldJump) and (chr(torow+65)+str(tocol)+':'+oldJump[-2:] not in oldJump) and (chr(torow+65)+str(tocol)!=oldJump[-5:-3]):
                        newJumps.append(oldJump+":"+chr(torow+65)+str(tocol))
                        if oldJump in newJumps:
                            newJumps.remove(oldJump)
    return newJumps          

def automatedMove(CB,player):
    if player=="black":
        opposingPlayer="red"
    else:
        opposingPlayer="black"
    possibles=getPossibles(CB,player)
    temp=[]
    maxIndex=0
    if len(possibles["jumps"])>0: 
        for index in range(len(possibles["jumps"])):
            if len(possibles["jumps"][index]) > len(possibles["jumps"][maxIndex]):
                maxIndex = index
        if len(possibles["jumps"][maxIndex])>5:
            if DEBUG:
                print("returning long jump ",possibles["jumps"][maxIndex])
                junk=input()
            return possibles["jumps"][maxIndex]
        else:
            for block in possibles["blocks"]:
                if block in possibles["jumps"]:
                    temp.append(block)
            if len(temp)>0:
                index=random.randint(0,len(temp)-1)
                if DEBUG:
                    print("returning jump that is a block ",temp[index])
                    junk=input()
                return temp[index]          
        index=random.randint(0,len(possibles["jumps"])-1)
        if DEBUG:
            print("returning random jump ",possibles["jumps"][index])
            junk=input()
        return possibles["jumps"][index]
               
    if len(possibles["blocks"]) > 0:
        index=random.randint(0,len(possibles["blocks"])-1)
        if DEBUG:
            print("returning block ",possibles["blocks"][index])
            junk=input()
        return possibles["blocks"][index]
               
    if len(possibles["crownings"]) > 0:
        index=random.randint(0,len(possibles["crownings"])-1)
        if DEBUG:
            print("returning crowning ",possibles["crownings"][index])
            junk=input()
        return possibles["crownings"][index]

    if len(possibles["moves"]) > 0:
        #CAN Enemy jump me next time?
        enemyP=getPossibles(CB,opposingPlayer)
        if len(enemyP["jumps"])>0:
            avoid=[]
            for jump in enemyP["jumps"]:
                for move in possibles["moves"]:
                    if move[3:5]==jump[3:5]:
                        avoid.append(move)
            if len(avoid)>0:
                index=random.randint(0,len(avoid)-1)            
                return avoid[index]
        if DEBUG:
            print("MOVES:",possibles["moves"])
        testSet=copy(possibles["moves"])
        for move in testSet:
            if DEBUG:
                print("Testing move ",move)
            copyCB = deepcopy(CB)
            fromRow=ord(move[0])-65
            fromCol=int(move[1])
            toRow=ord(move[3])-65
            toCol=int(move[4])
            t=copyCB[fromRow][fromCol]
            copyCB[fromRow][fromCol]=0                         
            copyCB[toRow][toCol]=t
            enemyP=getPossibles(copyCB,opposingPlayer)
            if DEBUG:
                print("ENEMY CAN JUMP THESE ", enemyP["jumps"])
            if len(enemyP["jumps"])>0:           
                if DEBUG:
                    print("Removing bad move ",move)
                possibles["moves"].remove(move)
                if DEBUG:
                    print("possibles after removal ",possibles["moves"])
                    junk=input()
        if DEBUG:
            print("SAFE MOVES = ", possibles["moves"])
        preferredMoves=[]
        if len(possibles["moves"])>0:
            for move in possibles["moves"]:
                if int(move[4])==0 or int(move[4])==7:
                    preferredMoves.append(move)
            if len(preferredMoves)>0:
                minDist=100 #
                bestMove=preferredMoves[0] #
                for eachMove in preferredMoves: #
                    centroids=centroid(CB,opposingPlayer)
                    dist=abs((ord(eachMove[0])-65)-centroids[0])+abs(int(eachMove[1])-centroids[1])
                    if dist < minDist: #
                        bestMove=eachMove #
                        minDist=dist
                #index=random.randint(0,len(preferredMoves)-1)
                index=preferredMoves.index(bestMove)
                if DEBUG:
                    print("PREFERRED move that does not put me into jumpable position:",preferredMoves[index])
                    junk=input()
                return preferredMoves[index]
            else:
                index=random.randint(0,len(possibles["moves"])-1)
                if DEBUG:
                    print("Random move that does not put me into jumpable position:",possibles["moves"][index])
                    junk=input()
                return possibles["moves"][index]
        else:
            possibles=getPossibles(CB,player)
            index=random.randint(0,len(possibles["moves"])-1)
            if DEBUG:
                print("randomly picking move ", possibles["moves"][index])
                junk=input()
            return possibles["moves"][index]

def centroid(CB,opposingPlayer):
    if opposingPlayer == "red":
        pieceSet = [1,2]
    else:
        pieceSet = [3,4]
    sumR=0
    sumC=0
    count=0
    for row in range(8):
        for col in range(8):
            if CB[row][col] in pieceSet:
                sumR=sumR+row
                sumC=sumC+col
                count+=1
    centroidR=sumR//count
    centroidC=sumC//count
    return centroidR,centroidC

import checkers_helper
checkers_helper.init(automatedMove)
    
