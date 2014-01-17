class PlayersController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  before_action :ensure_player_owner, only: [:edit, :update, :destroy]

  def index
    @contest = Contest.friendly.find(params[:contest_id])
    #@players = @contest.players
    #@referees = Referee.all
    @players = Player.search(params[:search]).paginate(:per_page => 10, :page => params[:page])
    if @players.length ==0
      flash.now[:info] = "There were no players that matched your search. Please try again!"
    end
  end

  def new
    contest = Contest.friendly.find(params[:contest_id])
    @player = contest.players.build
  end

  def create
    contest = Contest.friendly.find(params[:contest_id])
    @player = contest.players.build(acceptable_params)
    @player.user = current_user
    if @player.save
      flash[:success] = 'New Player created.'
      redirect_to @player
    else
      render 'new'
    end
  end

  def show
    @player = Player.friendly.find(params[:id])
  end

  def edit
  end

  def update
    if @player.update(acceptable_params)
      flash[:success] = 'Player updated.'
      redirect_to @player
    else
      render 'edit'
    end
  end

  def destroy
    @player.destroy
    redirect_to contest_players_path(@player.contest)
  end

  private

    def acceptable_params
      params.require(:player).permit(:name, :description, :downloadable, :playable, :upload)
    end

    def ensure_player_owner
      @player = Player.friendly.find(params[:id])
      ensure_correct_user(@player.user_id)
    end
end
