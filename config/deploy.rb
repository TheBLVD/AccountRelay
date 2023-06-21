# config valid for current version and patch releases of Capistrano
lock '~> 3.17.2'

set :application, 'account_relay'
set :repo_url, 'git@github.com:TheBLVD/AccountRelay.git'
set :branch, ENV.fetch('BRANCH', 'main')

# Deploy to the user's home directory
set :deploy_to, "/home/accountrelay/#{fetch :application}"

set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip
set :migration_role, :app

set :linked_dirs, %w[log public/system]

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system',
       'public/uploads'

append :linked_files, '.env.production'

# Only keep the last 5 releases to save disk space
set :keep_releases, 5
