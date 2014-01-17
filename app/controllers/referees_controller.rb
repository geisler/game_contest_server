class RefereesController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  before_action :ensure_contest_creator, except: [:index, :show]
  before_action :ensure_referee_owner, only: [:edit, :update, :destroy]

  def index
    @referees = Referee.search(params[:search]).paginate(:per_page => 10, :page => params[:page])
    if @referees.length ==0
      flash.now[:info] = "There were no referees that matched your search. Please try again!"
    end
  end

  def new
    @referee = Referee.new
  end

  def create
    @referee = current_user.referees.build(acceptable_params)
    if @referee.save
      flash[:success] = 'Referee created.'
      redirect_to @referee
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @referee.update(acceptable_params)
      flash[:success] = 'Referee updated.'
      redirect_to @referee
    else
      render 'edit'
    end
  end

  def show
    @referee = Referee.friendly.find(params[:id])
  end

  def destroy
    @referee.destroy
    flash[:success] = 'Referee deleted.'
    redirect_to referees_path
  end

  private

  def acceptable_params
    params.require(:referee).permit(:name,
                                    :rules_url,
                                    :players_per_game,
                                    :upload)
  end

  def ensure_referee_owner
    @referee = Referee.friendly.find(params[:id])
    ensure_correct_user(@referee.user_id)
  end
end
