require 'spec_helper'

describe Player do
  describe "available routes" do
    specify { expect(get(contest_players_path(1))).to be_routable }
    specify { expect(post(contest_players_path(1))).to be_routable }
    specify { expect(get(new_contest_player_path(1))).to be_routable }
    specify { expect(get(edit_player_path(1))).to be_routable }
    specify { expect(get(player_path(1))).to be_routable }
    specify { expect(patch(player_path(1))).to be_routable }
    specify { expect(delete(player_path(1))).to be_routable }
  end

  describe "unavailable routes" do
    #specify { expect(get(players_path)).not_to be_routable }
    specify { expect(get('/players')).not_to be_routable }
    #specify { expect(post(players_path)).not_to be_routable }
    specify { expect(post('/players')).not_to be_routable }
    #specify { expect(get(new_player_path)).not_to be_routable }
    specify { expect(get('/players/new')).not_to route_to(action: 'new') }
  end
end
