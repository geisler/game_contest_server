require 'fileutils'

FactoryGirl.define do
  factory :user do
    sequence(:username) { |i| "User #{i}" }
    email    "john.doe@example.com"
    password "password"
    password_confirmation "password"
    chat_url "http://example.com/path/to/chat"

    factory :admin do
      admin true
    end

    factory :contest_creator do
      contest_creator true
    end

    factory :banned_user do
      banned true
    end
  end

  factory :referee do
    sequence(:file_location) do |i|
      location = Rails.root.join('code',
				 'referees',
				 'test',
				 "FactoryGirl-fake-code-#{i}").to_s
      FileUtils.touch(location)
      location
    end
    sequence(:name) { |i| "Referee #{i}" }
    rules_url "http://example.com/path/to/rules"
    players_per_game 4
    user
  end

  factory :contest do
    user
    referee
    deadline Time.current + 1.day
    start Time.current + 2.days
    description "Contest Description Here"
    sequence(:name) { |i| "Contest #{i}" }
    contest_type "Generic Contest Type"
  end

  factory :match do
    to_create {|instance| instance.save(validate: false) }

    status "Unknown Status"
    completion Time.current
    earliest_start Time.current

    factory :contest_match do
      association :manager, factory: :contest

      before(:create) do |match|
	p = create(:player, contest: match.manager)
	match.manager.referee.players_per_game.times do
	  match.player_matches.build(player: p,
				     score: 1.0,
				     result: "Unknown Result")
	end
      end
    end

    factory :challenge_match do
      association :manager, factory: :referee

      before(:create) do |match|
	p = create(:player)
	match.manager.referee.players_per_game.times do
	  match.player_matches.build(player: p,
				     score: 1.0,
				     result: "Unknown Result")
	end
      end
    end
  end

  factory :player do
    user
    contest
    sequence(:file_location) do |i|
      location = Rails.root.join('code',
				 'players',
				 'test',
				 "FactoryGirl-fake-code-#{i}").to_s
      FileUtils.touch(location)
      location
    end
    description "Player Description Here"
    sequence(:name) { |i| "Player #{i}" }
  end

  factory :player_match do
    player
    association :match, factory: :contest_match
    score 1.0
    result "Unknown Result"

    factory :winning_match do
      result "Win"
    end

    factory :losing_match do
      result "Loss"
    end

    after(:create) do |player_match|
      if !player_match.match.valid?
	extra_pm = player_match.match.player_matches.where.not(id: player_match.id).first
	extra_pm.player.destroy
	extra_pm.destroy
      end
    end
  end
end
