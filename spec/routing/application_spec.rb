require 'spec_helper'

feature "NamedRoutes" do
  describe "available routes" do
    specify { expect(get(root_path)).to be_routable }

    specify { expect(get(signup_path)).to be_routable }
    specify { expect(get(login_path)).to be_routable }
    specify { expect(delete(logout_path)).to be_routable }
  end
end
