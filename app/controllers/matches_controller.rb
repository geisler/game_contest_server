class MatchesController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  def new
  end


  def show
    @match = Match.find(params[:id])
  end

  def index
    @tournament = Tournament.friendly.find(params[:tournament_id])
    @matches = @tournament.matches
  end
end
