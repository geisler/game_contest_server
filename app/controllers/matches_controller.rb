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
    match_limit = params[:match][:match_limit]
    if params[:match][:player_ids] && params[:match][:player_ids].any? { |player_id, use| Player.find(player_id).user_id == current_user.id}
        match_limit.to_i.times do 
            @match = @contest.matches.build(acceptable_params)
    	    @match.status = "waiting"
    	        if @match.save
		    flash[:success] = 'Match created.'
		else
		    flash.now[:danger] = 'Match not saved'
		    render 'new'
		    return
		end
	end
	redirect_to @contest
    else   	
        @match = @contest.matches.build(acceptable_params)
	flash.now[:danger] = 'You need to select at least one of your own players.'
	render action: 'new'
    end
  end

  def show
    @match = Match.friendly.find(params[:id])
  end

  def index
    if params[:tournament_id]
      @manager = Tournament.friendly.find(params[:tournament_id])
    elsif params[:contest_id]
      @manager = Contest.friendly.find(params[:contest_id])
    else
      flash[:danger] = "Unable to find matches"
      redirect_to root_path
    end
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
    @match.player_matches.each{ |m|m.destroy}
    @match.parent_matches.each{ |m|m.destroy}
    @match.child_matches.each{ |m|m.destroy}
    @match.destroy
    redirect_to @match.manager
  end


  private

  def acceptable_params
    params.require(:match).permit(:earliest_start, player_ids: @contest.players.try(:ids))
  end


end
