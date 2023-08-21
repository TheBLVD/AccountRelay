# frozen_string_literal: true

# using pool to share connection b/w application and sidekiq
# sidekiq required minimum connection of (2 + concurrency)
# https://github.com/mperham/sidekiq/blob/master/lib/sidekiq/redis_connection.rb#L51
pool_size = ENV.fetch('RAILS_MAX_THREADS', 10)
REDIS_POOL = ConnectionPool.new(size: pool_size) { Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')) }

Sidekiq.configure_server do |config|
  config.redis = REDIS_POOL

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
  config.redis = REDIS_POOL

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
