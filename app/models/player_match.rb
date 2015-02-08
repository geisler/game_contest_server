class PlayerMatch < ActiveRecord::Base
  belongs_to :player
  belongs_to :match , inverse_of: :player_matches

  validates :player,    presence: true
  validates :match,     presence: true

  default_scope -> { order("player_matches.score DESC") }
  scope :wins, -> { where(result: 'Win') }
  scope :losses, -> { where(result: 'Loss') }

  def self.search(player, search)
    if search.blank?
      player.player_matches
    else
      find_by_sql("SELECT pm1.* FROM players AS p1 INNER JOIN player_matches AS pm1 ON pm1.player_id = p1.id INNER JOIN matches ON matches.id = pm1.match_id INNER JOIN player_matches AS pm2 ON pm2.match_id = matches.id INNER JOIN players AS p2 ON pm2.player_id = p2.id WHERE p1.id = #{player.id} AND #{sanitize_sql ["p2.name = '%s'", search]}")
    end
  end
end
