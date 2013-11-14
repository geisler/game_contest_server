require 'spec_helper'

describe User do
  describe "available routes" do
    specify { expect(get(users_path)).to be_routable }
    specify { expect(post(users_path)).to be_routable }
    specify { expect(get(new_user_path)).to be_routable }
    specify { expect(get(edit_user_path(1))).to be_routable }
    specify { expect(get(user_path(1))).to be_routable }
    specify { expect(patch(user_path(1))).to be_routable }
    specify { expect(delete(user_path(1))).to be_routable }
  end
end
