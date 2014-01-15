class MatchesController < ApplicationController
  def show
    @match = Match.find(params[:id])
  end

  def index
    #@contest = Contest.find(params[:contest_id])
    @tournament = Tournament.find(params[:tournament_id])
    @matches = @tournament.matches
  end
end
