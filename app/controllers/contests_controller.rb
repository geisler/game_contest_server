class ContestsController < ApplicationController
  def index
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

  def show
    @contest = Contest.find(params[:id])
  end

  private

    def acceptable_params
      params.require(:contest).permit(:deadline, :start, :description, :name, :contest_type, :referee_id)
    end
end
