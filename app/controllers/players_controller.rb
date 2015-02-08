class PlayersController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  before_action :ensure_player_owner, only: [:edit, :update, :destroy]

  require 'will_paginate/array'

  def index
    @contest = Contest.friendly.find(params[:contest_id])
    @players = Player.search(params[:search]).paginate(:per_page => 10, :page => params[:page])
    if @players.length ==0
      flash.now[:info] = "There were no players that matched your search. Please try again!"
    end
  end

  def new
    contest = Contest.friendly.find(params[:contest_id])
    @player = contest.players.build
  end

  def create
    contest = Contest.friendly.find(params[:contest_id])
    @player = contest.players.build(acceptable_create_params)
    @player.upload = params[:player][:upload]
    @player.user = current_user
    if @player.save
      flash[:success] = 'New Player created.'
      redirect_to @player
    else
      render 'new'
    end
  end

  def show
    @player = Player.friendly.find(params[:id])
    @playermatch = PlayerMatch.search(@player, params[:search])
    @matches = PlayerMatch.search(@player, params[:search]).paginate(:per_page =>10, :page => params[:page])
  end

  def edit
  end

  def update
    if @player.update(acceptable_update_params)
      flash[:success] = 'Player updated.'
      redirect_to @player
    else
      render 'edit'
    end
  end

  def destroy
    @player.destroy
    redirect_to contest_players_path(@player.contest)
  end

  private

  def acceptable_update_params
     params.require(:player).permit(:name, :description, :downloadable, :playable, :upload)
  end

  def acceptable_create_params
     params.require(:player).permit(:name, :description, :downloadable, :playable)
  end

  def ensure_player_owner
    @player = Player.friendly.find(params[:id])
    ensure_correct_user(@player.user_id)
  end
end
