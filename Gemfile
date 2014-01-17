source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'libnotify'
  gem 'timecop'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec'

  gem 'spork-rails'
  gem 'guard-spork'
  gem 'childprocess'
end

group :development do
  gem 'guard-livereload', require: false
end

gem 'bcrypt-ruby', '~> 3.0.0'
gem 'active_link_to'
gem 'validates_timeliness', github: 'softace/validates_timeliness', branch: 'support_for_rails4'
gem 'friendly_id', '~> 5.0.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
#gem 'bootstrap-sass', '~> 2.3.2.1'
gem 'bootstrap-sass', github: 'thomas-mcdonald/bootstrap-sass'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'faker', '1.1.2'
gem 'will_paginate', '3.0.4'
#gem 'bootstrap-will_paginate', '0.0.9'
gem 'kaminari'

#for backend job scheduling
gem 'daemons'
gem 'clockwork'

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
