require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AccountRelay
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # create a logger with a file as a logging target
    config.logger = Logger.new('log/acctrelay.log')
    # set the minimum log level
    config.log_level = :warn

    # Enable Sidekiq
    config.active_job.queue_adapter = :sidekiq
  end
end
