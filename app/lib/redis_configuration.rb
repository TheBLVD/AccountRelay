# frozen_string_literal: true

class RedisConfiguration
  class << self
    def establish_pool(new_pool_size)
      @pool&.shutdown(&:close)
      @pool = ConnectionPool.new(size: new_pool_size) { new.connection }
    end

    delegate :with, to: :pool

    def pool
      @pool ||= establish_pool(pool_size)
    end

    def pool_size
      if Sidekiq.server?
        Sidekiq[:concurrency]
      else
        ENV['RAILS_MAX_THREADS'] || 5
      end
    end
  end

  def connection
    if namespace?
      Redis::Namespace.new(namespace, redis: raw_connection)
    else
      raw_connection
    end
  end

  def namespace?
    namespace.present?
  end

  def namespace
    ENV.fetch('REDIS_NAMESPACE', nil)
  end

  def url
    'redis://localhost:6379/1'
  end

  private

  def raw_connection
    Redis.new(url:, driver: :hiredis)
  end
end
