class ProgrammingLanguage < ActiveRecord::Base
  has_many :contest_managers
  has_many :players
end
