class ProgrammingLanguage < ActiveRecord::Base
  has_many :referees
  has_many :players
end
