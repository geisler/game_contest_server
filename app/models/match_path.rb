class MatchPath < ActiveRecord::Base
  belongs_to :parent_match, :class_name => 'Match'
  belongs_to :child_match, :class_name => 'Match'
end
