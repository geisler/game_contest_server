class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(acceptable_params)
    if (@user.save)
      # success!
      redirect_to @user
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

    def acceptable_params
      params.require(:user).permit(:username, :password, :password_confirmation, :email)
    end
end
