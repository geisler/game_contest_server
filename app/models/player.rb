class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest
  belongs_to :programming_language
end
