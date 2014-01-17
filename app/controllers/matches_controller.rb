class MatchesController < ApplicationController
  def show
    @match = Match.find(params[:id])
  end

  def index
    #@contest = Contest.friendly.find(params[:contest_id])
    @tournament = Tournament.friendly.find(params[:tournament_id])
    @matches = @tournament.matches
  end
end
