class MatchesController < ApplicationController
  def show
    @match = Match.find(params[:id])
  end

  def index
    @contest = Contest.find(params[:contest_id])
    @matches = @contest.matches
  end
end
