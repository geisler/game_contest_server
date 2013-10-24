class Contest < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest_manager
end
