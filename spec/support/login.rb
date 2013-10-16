def login(user, options = {})
  if options[:avoid_capybara]
    post sessions_path, username: user.username, password: user.password
  else
    visit login_path
    fill_in 'Username', with: user.username
    fill_in 'Password', with: user.password
    click_button 'Log In'
  end
end
