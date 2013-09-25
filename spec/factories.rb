FactoryGirl.define do
  factory :user do
    username "John Doe"
    email    "john.doe@example.com"
    password "password"
    password_confirmation "password"
  end
end
