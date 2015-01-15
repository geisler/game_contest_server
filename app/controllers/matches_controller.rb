class MatchesController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  before_action :ensure_contest_creator, only: [:edit, :update, :destroy]
 
 def new
   contest = Contest.friendly.find(params[:contest_id])
   @contest = Contest.friendly.find(params[:contest_id])
   @match = contest.matches.build
   @match.manager.players.each do |f|
	@match.player_matches.build(player: f )
   end
   #@match.earliest_start = Time.now
  
  end 


  def create	
    @contest = Contest.friendly.find(params[:contest_id])
    contest = Contest.friendly.find(params[:contest_id])
    @match = @contest.matches.build(acceptable_params)
     if params[:match][:player_ids] && params[:match][:player_ids].any? { |player_id, use| Player.find(player_id).user_id == current_user.id}
    	@match.status = "waiting"
    	    if @match.save
		flash[:success] = 'Match created.'
		redirect_to @match
    	    else
		render 'new'
            end
    else
	flash.now[:danger] = 'You need to select at least one of your own players.'
	render action: 'new'
    end
  end

  def show
    @match = Match.find(params[:id])
  end

  def index
    @tournament = Tournament.friendly.find(params[:tournament_id])
    @matches = @tournament.matches
  end

#  def edit
#    @match = Match.friendly.find(params[:id])
#  end


#  def update
#    @match = Match.frendly.find(params[:id])
#    @match.player_matches.each do |player_match|
#	player_match.destroy
#    end
#    if @match.update (acceptable_params)
#	flash[:success] = "Match updated."
#	redirect_to @match
#    else
#	render 'edit'
#    end
#  end

  def destroy
    @match = Match.friendly.find(params[:id])
    @match.player_matches.each{ |m| m.destroy}
    @match.match_paths.each{ |m| m.destroy}
    @match.destory
    redirect_to contest_matches_path(@match.contest)
  end


  private

  def acceptable_params
    params.require(:match).permit(:earliest_start, player_ids: @contest.players.try(:ids))
  end




end
