require 'spec_helper'

describe Contest do
  describe "available routes" do
    specify { expect(get(contests_path)).to be_routable }
    specify { expect(post(contests_path)).to be_routable }
    specify { expect(get(new_contest_path)).to be_routable }
    specify { expect(get(edit_contest_path(1))).to be_routable }
    specify { expect(get(contest_path(1))).to be_routable }
    specify { expect(patch(contest_path(1))).to be_routable }
    specify { expect(delete(contest_path(1))).to be_routable }
  end
end
