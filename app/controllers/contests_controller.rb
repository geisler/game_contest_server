class ContestsController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  before_action :ensure_contest_creator, except: [:index, :show]
  before_action :ensure_contest_owner, only: [:edit, :update, :destroy]


  def index
    @contests = Contest.search(params[:search]).paginate(:per_page => 10, :page => params[:page])
    if @contests.length == 0
      flash.now[:info] = "There were no contests that matched your search. Please try again!"
    end
  end

  def new
    @contest = Contest.new
  end

  def create
    @contest = current_user.contests.build(acceptable_params)
    if @contest.save
      flash[:success] = 'Contest created.'
      redirect_to @contest
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @contest.update(acceptable_params)
      flash[:success] = 'Contest updated.'
      redirect_to @contest
    else
      render 'edit'
    end
  end

  def show
    @contest = Contest.friendly.find(params[:id])
  end

  def destroy
    @contest.destroy
    redirect_to contests_path
  end

  private

  def acceptable_params
    params.require(:contest).permit(:deadline, :description, :name,  :referee_id)
  end

  def ensure_contest_owner
    @contest = Contest.friendly.find(params[:id])
    ensure_correct_user(@contest.user_id)
  end
end
