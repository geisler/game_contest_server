class RefereesController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  before_action :ensure_contest_creator, except: [:index, :show]

  def index
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
  end

  def show
    @referee = Referee.find(params[:id])
  end

  def destroy
  end

  private

    def acceptable_params
      params.require(:referee).permit(:name,
				      :rules_url,
				      :players_per_game,
				      :code)
    end
end
