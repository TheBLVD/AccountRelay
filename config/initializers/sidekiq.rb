# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { driver: :hiredis, url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  SidekiqUniqueJobs::Server.configure(config)

  # only warning/errors
  config.logger.level = Logger::WARN
end

# CLIENT
Sidekiq.configure_client do |config|
  config.redis = { driver: :hiredis, url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end

SidekiqUniqueJobs.configure do |config|
  config.reaper          = :ruby
  config.reaper_count    = 1000
  config.reaper_interval = 600
  config.reaper_timeout  = 150
  config.lock_ttl        = 50.days.to_i
end
