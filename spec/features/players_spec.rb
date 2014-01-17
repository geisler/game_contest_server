require 'spec_helper'

describe "PlayersPages" do
  let (:user) { FactoryGirl.create(:user) }
  let (:contest) { FactoryGirl.create(:contest) }
  let (:player) { FactoryGirl.create(:player, user: user, contest: contest) }
  let (:description) { 'Test Player Description' }
  let (:name) { 'Test Player' }
  let (:file_location) { Rails.root.join('spec', 'files', 'player.test') }
  let (:server_location) { Rails.root.join('code', 'players', 'test').to_s }

  subject { page }

  describe "create" do
    let (:submit) { 'Create Player' }

    before do
      login user
      visit new_contest_player_path(contest)
    end

    describe "invalid information" do
      describe "missing information" do
        it "should not create a player" do
          expect { click_button submit }.not_to change(Player, :count)
        end

        describe "after submission" do
          before { click_button submit }

          it { should have_alert(:danger) }
        end
      end
    end

    describe "valid information" do
      before do
        fill_in 'Name', with: name
        fill_in 'Description', with: description
        check('Allow others to compete against this player')
        uncheck('Allow others to download this player')
        attach_file('Upload file', file_location)
      end

      it "should create a player" do
        expect { click_button submit }.to change(Player, :count).by(1)
      end

      describe "redirects properly", type: :request do
        before do
          login user, avoid_capybara: true
          post contest_players_path(contest),
            player: { name: name,
              description: description,
              downloadable: false,
              playable: true,
              upload: fixture_file_upload(file_location) }
        end

        specify { expect(response).to redirect_to(player_path(assigns(:player))) }
      end

      describe "after submission" do
        let (:player) { Player.find_by(contest: contest, name: name) }

        before { click_button submit }

        specify { expect(player.user).to eq(user) }
        specify { expect(player.contest).to eq(contest) }

        it { should have_alert(:success, text: 'Player created') }
        it { should have_content(name) }
        it { should have_content(description) }
        #it { should have_content(file_contents) }
        it { should have_content('is available for matches') }
        it { should_not have_content('can be downloaded') }
        it { should have_link(player.contest.name,
                              href: contest_path(player.contest) ) }
        it { should have_link(player.user.username,
                              href: user_path(player.user) ) }
      end
    end
  end

  describe "edit" do
    let (:player) { FactoryGirl.create(:player, user: user) }
    let!(:orig_name) { player.name }
    let (:submit) { 'Update Player' }

    before do
      login user
      visit edit_player_path(player)
    end

    it { should have_field('Name', with: player.name) }
    it { should have_field('Description', with: player.description) }
    it { should have_unchecked_field('download') }
    it { should have_checked_field('compete') }

    describe "with invalid information" do
      before do
        fill_in 'Name', with: ''
        fill_in 'Description', with: description
      end

      describe "does not change data" do
        before { click_button submit }

        specify { expect(player.reload.name).not_to eq('') }
        specify { expect(player.reload.name).to eq(orig_name) }
      end

      it "does not add a new player to the system" do
        expect { click_button submit }.not_to change(Player, :count)
      end

      it "produces an error message" do
        click_button submit
        should have_alert(:danger)
      end
    end

    describe "with forbidden attributes", type: :request do
      let (:bad_path) { '/path/to/file' }
      before do
        login user, avoid_capybara: true
        patch player_path(player), player: { file_location: bad_path  }
      end

      specify { expect(player.reload.file_location).not_to eq(bad_path) }
    end

    describe "with valid information" do
      before do
        fill_in 'Name', with: name
        fill_in 'Description', with: description
        attach_file('Upload file', file_location)
      end

      describe "changes the data" do
        before { click_button submit }

        it { should have_alert(:success) }
        specify { expect(player.reload.name).to eq(name) }
        specify { expect(player.reload.description).to eq(description) }

        it "stores the contents of the file correctly" do
          expect_same_contents(player.reload.file_location, file_location)
        end
      end

      describe "redirects properly", type: :request do
        before do
          login user, avoid_capybara: true
          patch player_path(player), player: { name: name,
            description: description,
            playable: true,
            downloadable: false,
            upload: fixture_file_upload(file_location) }
        end

        specify { expect(response).to redirect_to(player_path(player)) }
      end

      it "does not add a new player to the system" do
        expect { click_button submit }.not_to change(Player, :count)
      end
    end
  end

  describe "destroy", type: :request do
    let!(:player) { FactoryGirl.create(:player, user: user) }

    before do
      login user, avoid_capybara: true
    end

    it "removes the player from the file system" do
      expect do
        delete player_path(player)
      end.to change{ Dir.entries(server_location).size }.by(-1)

      expect(File.exists?(player.file_location)).to be_false
    end

    describe "redirects properly" do
      before { delete player_path(player) }

      specify { expect(response).to redirect_to(contest_players_path(player.contest)) }
    end

    it "produces a delete message" do
      delete player_path(player)
      get response.location
      response.body.should have_alert(:success)
    end

    it "removes a player from the system" do
      expect { delete player_path(player) }.to change(Player, :count).by(-1)
    end
  end

  describe "show" do
    let (:player) { FactoryGirl.create(:player) }

    before { visit player_path(player) }

    it { should have_content(player.name) }
    it { should have_content(player.description) }
    it { should have_content('Player is available for matches') }
    it { should_not have_content('Player can be downloaded') }
    it { should have_content(player.contest.name) }
    it { should have_link(player.contest.name, href: contest_path(player.contest)) }
    it { should have_content(player.user.username) }
    it { should have_link(player.user.username, href: user_path(player.user)) }

    pending { should have_link('Challenge another player',
                               href: new_contest_player_path(contest)) }

    describe "show match" do
      let!(:player_match) { FactoryGirl.create(:player_match, player: player) }

      before { visit player_path(player) }

      it { should have_subheader(text: 'Match') }
      it { should have_content(player_match.result) }
      it { should have_link(player_match.match_id, match_path(player_match.match)) }

    end

    describe "more complete match history" do
      before do
        7.times { FactoryGirl.create(:winning_match, player: player) }
        4.times { FactoryGirl.create(:losing_match, player: player) }

        visit player_path(player)
      end

      it { should have_subheader(text: 'Matches') }
      it { should have_content('Win', count: 7) }
      it { should have_content('Loss', count: 4) }
      it { should have_content('Record: 7-4') }
    end

    describe "undefeated history" do
      before do
        5.times { FactoryGirl.create(:winning_match, player: player) }

        visit player_path(player)
      end

      it { should have_content('Win', count: 5) }
      it { should_not have_content('Loss') }
      it { should have_content('Record: 5-0') }
    end

    describe "win-less history" do
      before do
        8.times { FactoryGirl.create(:losing_match, player: player) }

        visit player_path(player)
      end

      it { should_not have_content('Win') }
      it { should have_content('Loss', count: 8) }
      it { should have_content('Record: 0-8') }
    end
  end

  describe "pagination" do
    before do
      30.times { FactoryGirl.create(:player, contest: contest); @slug = contest.slug }

      visit contest_players_path(contest)
    end

    it { should have_content('10 players') }
    it { should have_selector('div.pagination') }
    #it { should have_link('2', href: "/contests/1/players?page=2" ) }
    it { should have_link('2', href: "/contests/#{@slug}/players?page=2") }
    it { should have_link('3', href: "/contests/#{@slug}/players?page=3") }
    it { should_not have_link('4', href: "/contests/#{@slug}/players?page=4") }
  end

  describe 'search_error'do
    let(:submit) {"Search"}
    before do
      FactoryGirl.create(:player, name: "searchtest1", contest: contest)
      FactoryGirl.create(:player, name: "peter1", contest: contest)

      visit "/contests/1/players"
      fill_in 'search', with:';'
      click_button submit
    end
    after(:all)  { User.delete_all }
    it { should have_content("0 players") }
    it { should_not have_link('2') }#, href: "/contests?utf8=✓&direction=&sort=&search=searchtest4&commit=Search" ) }
    it {should have_alert(:info) }
  end
  describe 'search_partial' do
    let(:submit) {"Search"}
    before do
      FactoryGirl.create(:player, name: "searchtest1")
      FactoryGirl.create(:player, name: "peter1")
      FactoryGirl.create(:player, name: "searchtest2")
      FactoryGirl.create(:player, name: "peter2")
      FactoryGirl.create(:player, name: "searchtest9")
      FactoryGirl.create(:player, name: "peter9")
      FactoryGirl.create(:player, name: "searchtest4")
      FactoryGirl.create(:player, name: "peter4")
      FactoryGirl.create(:player, name: "searchtest5")
      FactoryGirl.create(:player, name: "peter5")
      FactoryGirl.create(:player, name: "searchtest6")
      FactoryGirl.create(:player, name: "peter6")
      FactoryGirl.create(:player, name: "searchtest7")
      FactoryGirl.create(:player, name: "peter7")
      FactoryGirl.create(:player, name: "searchtest8")
      FactoryGirl.create(:player, name: "peter8")
      visit "/contests/1/players"
      fill_in 'search', with:'te'
      click_button submit
    end
    after(:all)  { User.delete_all }
    it { should have_content("10 players") }
    it { should have_link('2') }
    it { should_not have_link('3') }
    # it { should_not have_link('3', href: "/contests?utf8=✓&direction=&sort=&search=te&commit=Search") }
  end

  describe 'search_pagination' do
    let(:submit) {"Search"}
    before do
      FactoryGirl.create(:player, name: "searchtest1")
      FactoryGirl.create(:player, name: "peter1")
      FactoryGirl.create(:player, name: "searchtest2")
      FactoryGirl.create(:player, name: "peter2")
      FactoryGirl.create(:player, name: "searchtest9")
      FactoryGirl.create(:player, name: "peter9")
      FactoryGirl.create(:player, name: "searchtest4")
      FactoryGirl.create(:player, name: "peter4")
      FactoryGirl.create(:player, name: "searchtest5")
      FactoryGirl.create(:player, name: "peter5")
      FactoryGirl.create(:player, name: "searchtest6")
      FactoryGirl.create(:player, name: "peter6")
      visit "/contests/1/players"
      fill_in 'search', with:'searchtest4'
      click_button submit
    end
    after(:all)  { User.delete_all }
    it { should have_content("1 player") }
    it { should_not have_link('2') }#, href: "/contests?utf8=✓&direction=&sort=&search=searchtest4&commit=Search" ) }
  end

  describe 'search' do
    let(:submit) { "Search" }

    before do
      FactoryGirl.create(:player, name: "searchtest")
      visit "/contests/1/players"
      fill_in 'search', with:'searchtest'
      click_button submit
    end

    it 'should return results' do
      should have_content('searchtest')
      should have_content('1 player')
    end
  end

  describe "show all" do
    before do
      5.times { FactoryGirl.create(:player, contest: contest) }

      visit contest_players_path(contest)
    end

    it "lists all the players for a contest in the system" do
      Player.where(contest: contest).each do |p|
        should have_selector('li', text: p.name)
        should have_link(p.name, player_path(p))
      end
    end
  end
end
