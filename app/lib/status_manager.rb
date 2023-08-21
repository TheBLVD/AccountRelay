# frozen_string_literal: true

# rubocop:disable all
require 'singleton'

class StatusManager
  include Singleton
  include Redisable

  # Redis key of a status
  # @param [Integer] id
  # @param [Symbol] type 'min_id' | 'max_id'
  # @return [String]
  def key(type, id)
    @type = type.to_s
    return "status:#{@type}:#{id}"
  end

  def fetch_min_id(user_id)
    Rails.logger.debug "REDIS FETCHING:::: #{user_id}"
    key = key('min_id', user_id)
    redis.get(key)
end 

def update_min_id(user_id, value)
    Rails.logger.debug "SETTING FETCHING:::: #{user_id} with #{value}"
    key = key('min_id', user_id)
    redis.set(key, value)
  end 

end 