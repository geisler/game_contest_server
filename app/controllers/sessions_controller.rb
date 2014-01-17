class SessionsController < ApplicationController
  before_action :ensure_user_logged_out, only: [:new, :create]
  before_action :ensure_user_logged_in, only: [:destroy]

  def new
  end

  def create
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      login user
      flash[:success] = 'Logged in.'
      redirect_to user
    else
      flash.now[:danger] = 'Invalid username or password'
      render 'new'
    end
  end

  def destroy
    logout
    flash[:info] = 'Logged out.'
    redirect_to root_path
  end
end
