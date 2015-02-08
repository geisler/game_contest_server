.PHONY: run contest manager clean

include player.mk

manager:
	nc -l -p $(port)

run: test_referee.rb
	./test_referee.py -p $(port) -n $(num_players) $(num_matches) $(timeout)

contest: $(PLAYER)
	./$(PLAYER).py -p $(port) -n '$(name)'
