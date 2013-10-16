class UsersController < ApplicationController
  before_action :ensure_user_signed_in, only: [:edit, :update]
  before_action :ensure_correct_user, only: [:edit, :update]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(acceptable_params)
    if @user.save
      flash[:success] = "Welcome to the site: #{@user.username}"
      login @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
  end

  def update
    if @user.update(acceptable_params)
      flash[:success] = "Your profile has been modified"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path
  end

  private

    def acceptable_params
      params.require(:user).permit(:username, :password, :password_confirmation, :email)
    end

    def ensure_user_signed_in
      unless logged_in?
	flash[:warning] = 'Unable to edit profile--not logged in.'
	redirect_to login_path
      end
    end

    def ensure_correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
    end
end
