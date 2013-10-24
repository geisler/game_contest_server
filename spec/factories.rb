FactoryGirl.define do
  factory :user do
    sequence(:username) { |i| "User #{i}" }
    email    "john.doe@example.com"
    password "password"
    password_confirmation "password"

    factory :admin do
      admin true
    end
  end

  factory :programming_language do
    name "One Language to Rule Them All"
  end

  factory :contest_manager do
    code_path "/path/to/manager/code"
    programming_language
  end

  factory :contest do
    user
    contest_manager
    description "Contest Description Here"
    documentation_path "/path/to/contest/docs"
  end

  factory :match_type do
    kind "One Match to Rule Them All"
  end

  factory :match do
    contest
    occurance Time.now
    match_type
    duration 1.0
  end

  factory :player do
    user
    contest
    code_path "/path/to/player/code"
    programming_language
  end

  factory :player_match do
    player
    match
    score 1.0
  end
end
