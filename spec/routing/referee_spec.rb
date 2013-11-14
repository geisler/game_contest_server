require 'spec_helper'

describe Referee do
  describe "available routes" do
    specify { expect(get(referees_path)).to be_routable }
    specify { expect(post(referees_path)).to be_routable }
    specify { expect(get(new_referee_path)).to be_routable }
    specify { expect(get(edit_referee_path(1))).to be_routable }
    specify { expect(get(referee_path(1))).to be_routable }
    specify { expect(patch(referee_path(1))).to be_routable }
    specify { expect(delete(referee_path(1))).to be_routable }
  end
end
