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
    description "Contest Description Here"
    sequence(:name) { |i| "Contest #{i}" }
  end

  factory :tournament do
    contest
    sequence(:name) { |i| "Tournament #{i}" }
    start Time.current
    tournament_type "round robin"
    status "waiting"
  end

  factory :player_tournament do
    player
    tournament
  end

  dummy_player = 0

  factory :match do
    to_create {|instance| instance.save(validate: false) }
    ignore { existing_players 0 }

    status "waiting"
    completion Time.current
    earliest_start Time.current

    factory :tournament_match do
      association :manager, factory: :tournament

      before(:create) do |match, evaluator|
        dummy_player = create(:player, contest: match.manager.contest)
        dummy_player.tournaments << match.manager
      end
    end

    factory :challenge_match do
      association :manager, factory: :referee

      before(:create) { |match| dummy_player = create(:player) }
    end

    after(:create) do |match, evaluator|
      num_players = match.manager.referee.players_per_game
      num_players -= evaluator.existing_players
      create_list(:player_match, num_players, player: dummy_player, match: match)
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
    association :match, factory: :tournament_match, existing_players: 1
    score 1.0
    result "Unknown Result"

    factory :winning_match do
      result "Win"
    end

    factory :losing_match do
      result "Loss"
    end
  end

end
