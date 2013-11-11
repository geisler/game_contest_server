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
    deadline Time.now
    start Time.now
    description "Contest Description Here"
    sequence(:name) { |i| "Contest #{i}" }
    contest_type "Generic Contest Type"
  end

  factory :match do
    status "Unknown Status"
    completion Time.now
    earliest_start Time.now

    factory :contest_match do
      association :manager, factory: :contest
    end

    factory :challenge_match do
      association :manager, factory: :referee
    end
  end


  factory :player do
    user
    contest
    sequence(:file_location) { |i| "/path/to/player/code/#{i}" }
    description "Player Description Here"
    sequence(:name) { |i| "Player #{i}" }
  end

  factory :player_match do
    player
    association :match, factory: :contest_match
    score 1.0
    result "Unknown Result"
  end
end
