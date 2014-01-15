require 'spec_helper'

describe Tournament do
  describe "available routes" do
    specify { expect(get(contest_tournaments_path(1))).to be_routable }
    specify { expect(post(contest_tournaments_path(1))).to be_routable }
    specify { expect(get(new_contest_tournament_path(1))).to be_routable }
    specify { expect(get(edit_tournament_path(1))).to be_routable }
    specify { expect(get(tournament_path(1))).to be_routable }
    specify { expect(patch(tournament_path(1))).to be_routable }
    specify { expect(delete(tournament_path(1))).to be_routable }
  end

  describe "unavailable routes" do
    #specify { expect(get(tournaments_path)).not_to be_routable }
    specify { expect(get('/tournaments')).not_to be_routable }
    #specify { expect(post(tournaments_path)).not_to be_routable }
    specify { expect(post('/tournaments')).not_to be_routable }
    #specify { expect(get(new_tournament_path)).not_to be_routable }
    specify { expect(get('/tournaments/new')).not_to route_to(action: 'new') }
  end
end
