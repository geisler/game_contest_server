class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new
    render :new
  end
end
