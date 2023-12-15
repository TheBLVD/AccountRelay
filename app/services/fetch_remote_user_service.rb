# frozen_string_literal: true

class FetchRemoteUserService < FetchRemoteActorService
  # Does a WebFinger roundtrip on each call, unless `only_key` is true
  def call(uri, id: true, prefetched_body: nil, break_on_redirect: false, only_key: false, suppress_errors: true,
           request_id: nil)
    actor = super
    return actor if actor.nil? || actor.is_a?(User)

    Rails.logger.debug { "Fetching user #{uri} failed: Expected User, got #{actor.class.name}" }
    raise Error, "Expected User, got #{actor.class.name}" unless suppress_errors
  end
end
