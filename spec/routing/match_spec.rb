require 'spec_helper'

describe Match do
  describe "available routes" do
    specify { expect(get(tournament_matches_path(1))).to be_routable }
    specify { expect(get(match_path(1))).to be_routable }
  end

  describe "unavailable routes" do
    #specify { expect(get(contest_match_path(1))).not_to be_routable }
    specify { expect(get('/contests/1/matches/)')).not_to be_routable }
    #specify { expect(post(contest_match_path(1))).not_to be_routable }
    specify { expect(post('/contests/1/matches/')).not_to be_routable }
    specify { expect(post(tournament_matches_path(1))).not_to be_routable }
    #specify { expect(get(new_contest_match_path(1))).not_to be_routable }
    specify { expect(get('/contests/1/matches/new')).not_to be_routable }
    specify { expect(get('/tournaments/1/matches/new')).not_to be_routable }
    #specify { expect(get(edit_match_path(1))).not_to be_routable }
    specify { expect(get('/matches/1/edit')).not_to be_routable }
    specify { expect(patch(match_path(1))).not_to be_routable }
    specify { expect(delete(match_path(1))).not_to be_routable }
    #specify { expect(get(matches_path)).not_to be_routable }
    specify { expect(get('/matches')).not_to be_routable }
    #specify { expect(post(matches_path)).not_to be_routable }
    specify { expect(post('/matches')).not_to be_routable }
    #specify { expect(get(new_match_path)).not_to be_routable }
    specify { expect(get('/matches/new')).not_to route_to(action: 'new') }
  end
end
