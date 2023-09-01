module AcctHandle
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def by_handle(handle)
      username, domain = username_and_domain(handle)
      where(username:, domain:).take
    end

    def username_and_domain(handle)
      match = handle.match(/^(.+)@(.+)$/)
      raise StandardError, "Incorrect handle: #{handle}" if !match || match.length < 2

      domain = match[2]
      username = match[1]
      [username, domain]
    end
  end
end
