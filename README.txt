Project Team:
Phil Brocker
Alex Sjoberg
David Nicholls
Juan Comboni
Justin Southworth
Nathan Lundell
Doug Brown

Jan 2014

I. Daemon

    We are using the clockwork ruby gem, which essentially creates cron jobs to run our scripts
at a given interval. We have a script in etc/initd called game_contest_server.sh which starts clockwork
daemon upon server start. Currently it runs the process from Alex Sjoberg's user directory (/home/asjoberg). The clock.rb file in the top level directory of the project contains the jobs and intervals to be run
by clcokwork.

    To start clockwork daemon manually you can use the following...
        - Background
            - clockworkd -d . start ./clock.rb --log
            - "-d" flag specifys the directory you would like to run it from
            - to stop the process use clockworkd stop
        - Foreground
            - clockwork ./clock.rb
            - to stop use control c

II. Program Flow

    Using clockwork as describe above the frontend to backend flow is as follows.
        1. Clockwork daemon is running scripts that check the database for tournament and matches
            - if a tournament is found that needs to be run, tournament_runner.rb will create database
            entries for the needed mathces.
            - if a match is found that needs to be run, match_runnner.rb will use match_wrapper.rb to run
            the match and enter the results into the database.
        2. Match_Wrapper.rb starts a referee telling it which port to communicate to match_wrapper on.
        The referee then responds with the port that it would like the players to communicate on.
        Match_wrapper then starts the players telling them the port to communicate to the referee on and
        also passes the players name which they will communicate to the referee so that it can accurately
        report results to be stored in the database.

III. Referees
    (example can be found in examples/test_referee.rb)

    Currently to be a referee you must:
        1. Accept a port through the '-p' command line argument
        2. Accept a number of players per game through '-n' command line argument
        3. Use that port to send the match_wrapper the port number you want your players to connect on
        4. The referee needs to accept player names from each player as they connect to be used in
        sending results to match_wrapper to ensure correct databse result entries.
        5. Send us the game result for each player in the form... "PlayerName|Result|Score" , with each
        player result being sent seperatley.
            - an example would be... Bob|Win|5
    NOTE:
        1. When communicating with the match_wrapper(or any ruby program) ensure that you put a newline
    ("\n") at the end of each message. This is becasue ruby uses newline to signal the end of input.
        2. Referees MUST include shebang (#!) so that the shell can run them
            - example: #! /usr/bin/env python
        3. Referees MUST also be written so that they can be executable

IV. Players
    (example can be found in examples/test_player.rb)

    Currently to be a player you must:
        1. Accept a port through the '-p' command line argument
        2. Accept a name through the '--name' command line argument
        3. They need to connect to the referee and send them their specified name

    NOTE:
        1. Players MUST include shebang (#!) so that the shell can run them
            - example: #! /usr/bin/env python
        2. Players MUST also be written so that they can be executable

V. Libary Imports

VI. Future Work
    - Finish python checkers helper library
    - Individual challenge both frontend and backend
    - Allowing games to be played that are more than 2 players
        - the match_wrapper should already support this, the biggest changes will take place in
        the match_runner
    - Allow for multiple rounds per match (currently this must be done in the referee)
    - Allow brackets to be customized from the frontend (currently randomly created)
    - Compile players when uploaded (currently they must be executable)
    - Test uploaded players and referees to ensure they interact with match_wrapper correctly
    - Logging and recording games for playback
    - Visually displaying games as they are played
    - Add more tournament types
    - Imporve error checking, such as if the player or referee dies
    - Support queueing of matches in the daemon. Currently launches a match every 10 seconds regardless of
        whether the previous one has finished or not. Could cause serious performance issues
    - Much more robust unit testing of the backend.
    - Create Matches page with pagination and search
    - Add download player functionality

VII. Known Bugs
    - Round Robin tournaments are currently never set to completed. Need a way to check that all matches are completed and set tournament status
    - Children are not being reaped properly in many cases in match_wrapper.rb
    - Occasionally when running lots of games, the db will be locked and we will fail to write the results
    - Checkers needs a max number of moves or too many games time out
