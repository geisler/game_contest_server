#include <iostream>
#include <cstdlib>
#include <string>
#include <random>

#include "socketstream.h"

int main(int argc, char **argv) {
    net::socketstream referee("localhost", std::atoi(argv[1]));

    referee << argv[2] << std::endl;

    std::random_device dev;
    std::default_random_engine engine(dev());
    std::uniform_int_distribution<int> uniform(0, 25);

    std::string buffer;
    bool done = false;
    while (!done) {
	getline(referee, buffer);
	if (buffer == "move") {
	    char output = 'a' + uniform(engine);
	    referee << output << std::endl;
	    std::cout << "Sending " << output << std::endl;
	} else if (buffer.find("wins") != std::string::npos) {
	    done = true;
	    std::cout << buffer << std::endl;
	}
    }

    return 0;
}
