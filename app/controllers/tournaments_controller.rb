class TournamentsController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  before_action :ensure_contest_creator, except: [:index, :show]
  before_action :ensure_contest_owner, only: [:new ,:edit, :update , :destroy]

  def new
    contest = Contest.friendly.find(params[:contest_id])
    @tournament = contest.tournaments.build
    @tournament.contest.players.each do |f|
      @tournament.player_tournaments.build(player: f )
    end
    @tournament.start = Time.now
  end

  def create
    @contest = Contest.friendly.find(params[:contest_id])
    @tournament = @contest.tournaments.build(acceptable_params)
    @tournament.status = "waiting"
    if @tournament.save
      flash[:success] = 'Tournament created.'
      redirect_to @tournament
    else
      render 'new'
    end
  end

  def index
    @contest = Contest.friendly.find(params[:contest_id])
    @tournaments = Tournament.search(params[:search]).paginate(:per_page => 10, :page => params[:page])
    if @tournaments.length == 0
      flash.now[:info] = "There were no tournaments that matched your search. Please try again!"
    end
  end

  def edit
    @tournament = Tournament.friendly.find(params[:id])
  end

  def update
    @tournament = Tournament.friendly.find(params[:id])
    @tournament.player_tournaments.each do |player_tournament|
      player_tournament.destroy
    end
    if @tournament.update(acceptable_params)
      flash[:success] = "Tournament updated."
      redirect_to @tournament
    else
      render 'edit'
    end
  end

  def show
    @tournament = Tournament.friendly.find(params[:id])
  end

  def destroy
    @tournament = Tournament.friendly.find(params[:id])
    @tournament.destroy
    redirect_to contest_tournaments_path(@tournament.contest)
  end

  private

  def acceptable_params
    # Status should not be acceptable.
    # The backend should set it.
    params.require(:tournament).permit(:name , :start, :tournament_type, player_ids: @contest.players.try(:ids))
  end

  def ensure_contest_owner
    if params.include? :contest_id
      @contest = Contest.friendly.find(params[:contest_id])
      ensure_correct_user(@contest.user_id)
    elsif params.include? :id
      @contest = Tournament.friendly.find(params[:id]).contest
      ensure_correct_user(@contest.user_id)
    end
  end

end
