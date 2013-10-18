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
end
