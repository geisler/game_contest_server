#! /usr/bin/env ruby

require_relative 'match_wrapper'

class MockPlayer
    attr_accessor :file_location , :name
    def initialize(file_location,name)
        self.file_location = file_location
        self.name = name
    end
end

p1 = MockPlayer.new("./checkers_player.py","first")
p2 = MockPlayer.new("./checkers_player.py", "second")
ref = MockPlayer.new("./checkers_ref.py", "ref")

match_wrapper = MatchWrapper.new(ref, 2, 5, [p1, p2])
match_wrapper.run_match

puts( match_wrapper.result)


