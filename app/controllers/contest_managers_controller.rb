class ContestManagersController < ApplicationController
  def index
  end

  def new
    @contest_manager = ContestManager.new
  end

  def create
    @contest_manager = ContestManager.new(acceptable_params)
    if @contest_manager.save
      flash[:success] = 'Contest Manager created.'
      redirect_to @contest_manager
    else
      render 'new'
    end
  end

  def edit
  end

  def update
  end

  def show
  end

  def destroy
  end

  private

    def acceptable_params
      params.require(:contest_manager).permit(:programming_language_id, :code)
    end
end
