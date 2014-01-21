#! /usr/bin/env python3


import cTurtle
import math
import random
from checkers_ref_helper import *

EMPTY=0
INCs=[-1,1]
VALID_RANGE=range(8)
DEBUG=False
VISIBLE=True

def drawCircleCentered(t,radius):
    pos=t.position()
    t.up()
    t.forward(radius)
    t.down()
    t.lt(90)
    t.circle(radius)
    t.up()
    t.setpos(pos)
    t.down()

def rowToLocation(row,size):
    return (4*size)-(size*row)

def colToLocation(col,size):
    return -(4*size)+(size*col)

def drawSquare(t,x,y,size,color):
    t.up()
    t.goto(x,y)
    t.down()
    t.setheading(0)
    t.color(color)
    t.begin_fill()
    for i in range(4):
        t.forward(size)
        t.right(90)
    t.end_fill()

def drawBlackRedRow(t,x,y,size):
    for i in range(4):
        drawSquare(t,x,y,size,"black")
        x=x+size
        drawSquare(t,x,y,size,"#009900")
        x=x+size

def drawRedBlackRow(t,x,y,size):
    for i in range(4):
        drawSquare(t,x,y,size,"#009900")
        x=x+size
        drawSquare(t,x,y,size,"black")
        x=x+size

def drawCheckerBoard(t,x,y,size):
    for i in range(4):
        drawRedBlackRow(t,x,y,size)
        y=y-size
        drawBlackRedRow(t,x,y,size)
        y=y-size

def drawChecker(t,row,column,color,size,king):
    t.color("black",color)
    t.up()
    y=rowToLocation(row, size)-(size//2)
    x=colToLocation(column,size)+(size//2)
    t.goto(x,y)
    t.down()
    t.begin_fill()
    ps=t.pensize()
    t.pensize(2)
    drawCircleCentered(t,size//2)
    t.end_fill()
    drawCircleCentered(t,size//3)
    drawCircleCentered(t,size//6)
    t.pensize(ps)
    if king:
        drawStar(t,x,y,size)

def drawStar(t,x,y,size):
    t.color("yellow","yellow")
    t.up()
    t.goto(x-(.16*size),y-(.24*size))
    t.down()
    t.begin_fill()
    t.setheading(108)
    t.forward(size//3)
    for i in range(5):
        t.right(72)
        t.forward(size//3)
    t.end_fill()

def labelBoard(t,size):
    t.up()
    t.goto(-(4*size)+8,(4.05*size))
    t.down()
    t.pencolor('#000000')
    for i in range(8):
        t.write("COL " + str(i),font=("Arial",12,"bold"))
        t.up()
        t.forward(size)
        t.down()
    t.up()
    t.goto(-(5.2*size),(3.4*size))
    t.down()
    for i in range(8):
        t.write("ROW " + chr(65+i),font=("Arial",12,"bold"))
        t.up()
        t.goto(-(5.2*size),((4*size)+(i*-size)-(1.7*size)))
        t.down()   

def fillCheckerBoard(t,size,CB):
    t.tracer(False)  
    drawCheckerBoard(t,-240,240,size)
    labelBoard(t,size)
    for row in range(8):
        for col in range(8):
            if CB[row][col]!=0:
                if CB[row][col] in [1,2]:
                    color="red"
                    player="red"
                else:
                    color="gray"
                    player="black"
                king=False
                if CB[row][col] in [2,4]:
                    king=True
                drawChecker(t,row,col,color,size,king)
    t.tracer(True)

def validMove(CB,move,player):
    possibles=getPossibles(CB,player)
    if len(possibles["jumps"])>0:
        if move not in possibles["jumps"]:
            print("A jump must be taken!!!")
            return False
        else:
            return True
    if move not in possibles["moves"]: #includes crowning and blocking moves
        print ("Invalid move!!!!")
        return False
    else:
        return True 

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
    return possibles

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
                    and ((oldJump[-2:]+":"+chr(torow+65)+str(tocol)) not in oldJump) and ((chr(torow+65)+str(tocol)+':'+oldJump[-2:] not in oldJump)) and (chr(torow+65)+str(tocol)!=oldJump[-5:-3]):
                        newJumps.append(oldJump+":"+chr(torow+65)+str(tocol))
                        if oldJump in newJumps:
                            newJumps.remove(oldJump)
    return newJumps          
            
def makeMove(t,CB,move,player,size,possibles):
    if VISIBLE:
        t.tracer(False)  
    if move in possibles["crownings"]:
        row=ord(move[0])-65
        col=int(move[1])
        CB[row][col]+=1
    #in case a multiple jump
    while len(move)>=5:
        fromRow=ord(move[0])-65
        fromCol=int(move[1])
        toRow=ord(move[3])-65
        toCol=int(move[4])
        #get graphic x,y from row,col
        y=rowToLocation(fromRow, size)
        x=colToLocation(fromCol, size)
        #blank out where the checker was
        if VISIBLE:
            drawSquare(t,x,y,size,"black")
        #change the logical board
        temp=CB[fromRow][fromCol]
        CB[fromRow][fromCol]=0                         
        CB[toRow][toCol]=temp
        #is this a king?
        king=False
        if temp in[2,4]:
            king=True
        if VISIBLE:
            if player=="black":
                drawChecker(t,toRow,toCol,"gray",size,king)
            else:
                drawChecker(t,toRow,toCol,"red",size,king)
        #Was this a jump? Remove the intervening checker
        if math.fabs(fromRow-toRow)>1:
            tweenRow=(fromRow+toRow)//2
            tweenCol=(fromCol+toCol)//2
            CB[tweenRow][tweenCol]=0
            y=rowToLocation(tweenRow, size)
            x=colToLocation(tweenCol, size)
            if VISIBLE:
                drawSquare(t,x,y,size,"black")
        move=move[3:]
    t.tracer(True)

def switchPlayers(player):
    #switch players
    if player=="black":
        player="red"
    else:
        player="black"
    return player

def readCheckerFile(CB):
    fileName="" #input("Enter a file name to start the game (prefix and .txt) => ")
    if fileName!="":
        inFile=open(fileName,"r")
        player=inFile.readline()
        for row in inFile:
            newRow=[]
            for item in row:
                if item !="\n":
                    newRow.append(int(item))
            CB.append(newRow)
        inFile.close()
        return player[:-1]
    else:
        newGame=[[0,1,0,1,0,1,0,1],[1,0,1,0,1,0,1,0], [0,1,0,1,0,1,0,1], [0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0], [3,0,3,0,3,0,3,0], [0,3,0,3,0,3,0,3], [3,0,3,0,3,0,3,0]]
        for row in newGame:
            CB.append(row)
        p=random.randint(0,1)
        if p==0:
            return "black"
        else:
            return "red"
    
def writeGameState(CB,player):
    fileName=input("Enter a file name to save the game (prefix and .txt) => ")
    if fileName!="":
        outFile=open(fileName,"w")
        outFile.write(player+"\n")
        for row in CB:
            for item in row:
                outFile.write(str(item))
            outFile.write("\n")
        outFile.close()
    else:
        print("Game not saved")

def showBoard(CB):
    print("  0 1 2 3 4 5 6 7 ")
    for row in range(8):
        line=chr(row+65)+" "
        for col in range(8):
            line+=str(CB[row][col])+" "
        print(line)

def win(CB):
    for i in range(2):
        if i==0:
            player="red"
            opPlayer="black"
            tokens=[1,2] #red tokens
        else:
            player="black"
            opPlayer="red"
            tokens=[3,4]
        count=0
        for row in range(8):
            for col in range(8):
                if CB[row][col] in tokens:
                    count+=1
        if count==0:
            return True,opPlayer
        count=0
        possibles=getPossibles(CB,player)
        for key in possibles:
            if len(possibles[key])>=1:
                count+=1
        if count==0:
            return True,opPlayer
    return False,"none"

def labelGameStats(t,size,PlayerB,PlayerR,Bwin,Rwin,total):
    t.tracer(False)
    t.up()
    t.goto((4*size)+10,(3.5*size))
    t.down()
    t.pencolor("red")
    t.write("RED",font=("Arial",12,"bold"))
    t.up()
    t.goto((4*size)+10,(3*size))
    t.down()
    t.write(str(Rwin) + "/" + str(total),font=("Arial",12,"bold"))
    t.up()
    t.goto((4*size)+10,(-3*size))
    t.down()
    t.pencolor('#000000')
    t.write("BLACK",font=("Arial",12,"bold"))
    t.up()
    t.goto((4*size)+10,(-3.5*size))
    t.down()
    t.write(str(Bwin) + "/" + str(total),font=("Arial",12,"bold"))
    t.tracer(True)
    

            
def checkers(CB,bob,PlayerB,PlayerR,Bwin,Rwin,totalPlayed):
    player=readCheckerFile(CB)
    print(player, "goes first")
    SIZE=60
    if VISIBLE:
        fillCheckerBoard(bob,SIZE,CB)
        labelGameStats(bob,SIZE,PlayerB,PlayerR,Bwin,Rwin,totalPlayed)
    move=''
    while move != 'exit' and not win(CB)[0]:
        possibles=getPossibles(CB,player)
        if player=="red":
            move=P2.automatedMove(CB,player)
        else:
            move=P1.automatedMove(CB,player)
        countBadMoves=1
        #Until a valid move or exceeds allowed number of bad move trys
        while ((move!="exit") and (not (validMove(CB,move,player)))) and (countBadMoves!=3):
            countBadMoves+=1
            if player=="red":
                move=P2.automatedMove(CB,player)
            else:
                move=P1.automatedMove(CB,player)
        #terminate due to bad moves or exit entered (and save state)
        if countBadMoves==3 or move=="exit":
            if countBadMoves==3:
                print("Game terminated because player ", player, " refused to make a valid move!")
            else:
                writeGameState(CB,player)
            return       
        #All good - make move!
        makeMove(bob,CB,move,player,SIZE,possibles)
        #showBoard(CB)
        player=switchPlayers(player)
    return win(CB)[1]

def rateBoard(CB):
    score=0
    for row in CB:
        for col in row:
            if col == 3:
                score += 1
            elif col == 4:
                score += 2
    return score

def tourney(PlayerB,PlayerR):
    bob=cTurtle.Turtle()
    Rwin=0
    Bwin=0
    iters=1
    score=0
    for i in range(1,iters+1):
        CB=[]
        print("Game:",i)
        result=checkers(CB,bob,PlayerB,PlayerR,Bwin,Rwin,i-1)
        bob.clear()
        if result=="black":
            Bwin+=1
        else:
            Rwin+=1
        #sys.stdout.write(".")
        score+=rateBoard(CB)
        print()
        print("Black wins = ",Bwin)
        print("Red wins = ",Rwin)
        print("Black average score = ",score/i)
    report_results(Bwin,Rwin) #On the assumption p1 is always black, and p2 red
    return
    
#run the game!!!!
tourney("black","red")
print("Tourney Over")
