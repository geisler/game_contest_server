class RefereesController < ApplicationController
  def index
  end

  def new
    @referee = Referee.new
  end

  def create
    @referee = Referee.new(acceptable_params)
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
  end

  def destroy
  end

  private

    def acceptable_params
      params.require(:referee).permit(:programming_language_id, :code)
    end
end
