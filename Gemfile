source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.1'

gem 'active_model_serializers', '~> 0.10.0'
gem 'addressable', '~> 2.8'
# HTTP
gem 'http', '~> 5.1'
gem 'http_accept_language', '~> 2.1'
gem 'httplog', '~> 1.6.2'
# JSON-LD
gem 'json-ld'
gem 'json-ld-preloaded', '~> 3.2'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'oj', '~> 3.13'
gem 'rails', '~> 6.1.7', '>= 6.1.7.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'dotenv-rails'
gem 'listen', '~> 3.3'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Processing Jobs
gem 'redis'
gem 'sidekiq'
gem 'sidekiq-scheduler', '~> 4.0'

# Datadog
gem 'ddtrace', require: 'ddtrace/auto_instrument'
gem 'dogstatsd-ruby', '~> 5.6'
gem 'google-protobuf', '~> 3.0'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Deployment 
  # Use Capistrano for deployment
  gem "capistrano", "~> 3.17", require: false
  gem 'capistrano-rails', '~> 1.1.0'
  gem 'capistrano-rbenv', '~> 2.2'
  gem 'capistrano-passenger', '~> 0.2.0'
  gem 'capistrano-bundler'

  # Required
  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver', '>= 4.0.0.rc1'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
