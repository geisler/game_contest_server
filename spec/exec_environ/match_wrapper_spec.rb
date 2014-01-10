require 'spec_helper'

describe MatchWrapper do
    before :each do
        @match_wrapper = MatchWrapper.new("x" , "y.rb" , "z.py")
    end

    describe "#new" do
        it "should exist" do
            @match_wrapper.should be_an_instance_of MatchWrapper 
        end
    end
end

