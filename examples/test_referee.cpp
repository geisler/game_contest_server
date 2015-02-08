#include <iostream>
#include <cstdlib>
#include <string>
#include <vector>

#include "socketstream.h"

class PlayerConnection {
    net::socketstream *stream;
    std::string name;
    bool won;
    double score;

  public:
    PlayerConnection(net::socketstream* in_stream)
	: stream(in_stream), won(false), score(0.0)
    {
#if defined(USE_TELNET)
	std::getline(*stream, name, '\r');
	stream->ignore(1);
#else
	std::getline(*stream, name);
#endif
    }

    std::string getline() const {
	std::string buffer;
#if defined(USE_TELNET)
	std::getline(*stream, buffer, '\r');
	stream->ignore(1);
#else
	std::getline(*stream, buffer);
#endif

	return buffer;
    }

    void sendline(std::string line) {
	*stream << line << std::endl;
    }

    void set_won() { won = true; }
    void set_score(double new_score) { score = new_score; }

    std::string get_results() const {
	std::string result = name;
	result += "|";
	if (won) {
	    result += "Win";
	} else {
	    result += "Loss";
	}
	result += "|";
	result += std::to_string(score);

	return result;
    }

    std::string get_name() const { return name; }
};

int main(int argc, char **argv) {
    net::socketstream manager("localhost", std::atoi(argv[1]));
    net::server referee;

    manager << referee.get_port() << std::endl;

    int num_players = std::atoi(argv[2]);
    std::vector<PlayerConnection> players;
    for (int i = 0; i < num_players; ++i) {
	players.push_back(PlayerConnection(referee.serve()));
    }

    std::string buffer;
    std::string winner;
    bool done = false;
    while (!done) {
	for (int i = 0; !done && i < num_players; ++i) {
	    players[i].sendline("move");

	    std::cout << "Getting line from " << players[i].get_name() << ": (";
	    buffer = players[i].getline();
	    std::cout << buffer << ")" << std::endl;

	    if (buffer == "w") {
		winner = players[i].get_name();
		std::cout << winner << " won!!!" << std::endl;
		players[i].set_won();
		done = true;
	    }
	}
    }

    for (int i = 0; i < num_players; ++i) {
	manager << players[i].get_results() << std::endl;
	players[i].sendline(winner + " wins!");
    }

    return 0;
}
