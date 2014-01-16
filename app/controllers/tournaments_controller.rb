class TournamentsController < ApplicationController
  before_action :ensure_user_logged_in, except: [:index, :show]
  before_action :ensure_contest_creator, except: [:index, :show]
  before_action :ensure_contest_owner, only: [:new ,:edit, :update ]

    def new
        contest = Contest.find(params[:contest_id])
        @tournament = contest.tournaments.build
        @tournament.contest.players.each do |f|
            @tournament.player_tournaments.build(player: f )
        end 
        @players = @tournament.players
        puts 'players yo'
        puts @players
        puts "the build succeeded!!!!!\n" ,  @tournament.player_tournaments[1].player.name
    end

    def create
        @contest = Contest.find(params[:contest_id])
        puts "Acceptable Params = #{acceptable_params}"
        @tournament = @contest.tournaments.build(acceptable_params)
        if @tournament.save
            flash[:success] = 'Tournament created.'
            redirect_to @tournament
        else
            render 'new'
        end
    end

    def index
        @contest = Contest.find(params[:contest_id])
        @tournaments = Tournament.paginate(page: params[:page], :per_page => 10)
    end

    def edit
        @tournament = Tournament.find(params[:id])
    end
       
    def update
        @tournament = Tournament.find(params[:id])
        if @tournament.update(accpetable_params)
            flash[:success] = "Tournament updated."
            redirect_to @tournament
        else
            render 'edit'
        end
    end

    def show 
        @tournament = Tournament.find(params[:id])
    end

    def destroy
        @tournament = Tournament.find(params[:id])
        @tournament.destroy
        redirect_to contest_tournaments_path(@tournament.contest)
    end

    private

    def acceptable_params
        params.require(:tournament).permit(:name , :start, :tournament_type, player_ids: @contest.players.try(:ids))
    end

    def ensure_contest_owner
      if params.include? :contest_id
          @contest = Contest.find(params[:contest_id])
          ensure_correct_user(@contest.user_id)
      elsif params.include? :id
          @contest = Tournament.find(params[:id]).contest
          ensure_correct_user(@contest.user_id)
      end
    end

end
