class MatchesController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
 
 def new
   contest = Contest.friendly.find(params[:contest_id])
   @contest = Contest.friendly.find(params[:contest_id])
   @match = contest.matches.build
   @match.manager.players.each do |f|
	@match.player_matches.build(player: f )
   end
   @match.earliest_start = Time.now
  
  end 


  def create
    @contest = Contest.friendly.find(params[:contest_id])
    @match = @contest.matches.build(acceptable_params)
    @match.player_ids << params[:match][:player_id] 
    @match.status = "waiting"
    if @match.save
	flash[:success] = 'Match created.'
	redirect_to @contest
    else
	flash.now[:danger] = 'Unable to create Challenge'
	render 'new'
    end
  end

  def show
    @match = Match.find(params[:id])
  end

  def index
    @tournament = Tournament.friendly.find(params[:tournament_id])
    @matches = @tournament.matches
  end


  private

  def acceptable_params
    params.require(:match).permit(:earliest_start, player_ids: @contest.players.try(:ids))
  end




end
