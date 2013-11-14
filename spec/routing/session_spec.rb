require 'spec_helper'

describe "Session" do
  describe "available routes" do
    specify { expect(post(sessions_path)).to be_routable }
    specify { expect(get(new_session_path)).to be_routable }
    specify { expect(delete(session_path(1))).to be_routable }
  end

  describe "unavailable routes" do
    specify { expect(get(sessions_path)).not_to be_routable }
    specify { expect(get(session_path(1))).not_to be_routable }
#    specify { expect(get(edit_session_path(1))).to raise_error }
    specify { expect(get('/sessions/1/edit')).not_to be_routable }
    specify { expect(patch(session_path(1))).not_to be_routable }
  end
end
