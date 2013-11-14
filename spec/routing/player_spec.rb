require 'spec_helper'

describe Player do
  describe "available routes" do
    specify { expect(get(players_path)).to be_routable }
    specify { expect(post(players_path)).to be_routable }
    specify { expect(get(new_player_path)).to be_routable }
    specify { expect(get(edit_player_path(1))).to be_routable }
    specify { expect(get(player_path(1))).to be_routable }
    specify { expect(patch(player_path(1))).to be_routable }
    specify { expect(delete(player_path(1))).to be_routable }
  end
end
