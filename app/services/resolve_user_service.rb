# frozen_string_literal: true

class ResolveUserService < BaseService
  include WebfingerHelper
  include Redisable
  include Lockable

  # Find or create an user record for a remote user. When creating,
  # look up the user's webfinger and fetch ActivityPub data
  # @param [String, User] uri URI in the username@domain format or user record
  # @param [Hash] options
  # @option options [Boolean] :redirected Do not follow further Webfinger redirects
  # @option options [Boolean] :skip_webfinger Do not attempt any webfinger query or refreshing account data
  # @option options [Boolean] :skip_cache Get the latest data from origin even if cache is not due to update yet
  # @option options [Boolean] :suppress_errors When failing, return nil instead of raising an error
  # @return [User]
  def call(uri, options = {})
    return if uri.blank?

    process_options!(uri, options)

    # First of all we want to check if we've got the user
    # record with the URI already, and if so, we can exit early

    @user ||= User.find_remote(@username, @domain)

    return @user if @user&.local? || @domain.nil? || !webfinger_update_due?

    # At this point we are in need of a Webfinger query, which may
    # yield us a different username/domain through a redirect
    Rails.logger.debug 'PROCESS WEBFINGER'
    process_webfinger!(@uri)

    # Because the username/domain pair may be different than what
    # we already checked, we need to check if we've already got
    # the record with that URI, again

    @user ||= User.find_remote(@username, @domain)

    return @user if @user&.local? || gone_from_origin? || !webfinger_update_due?

    # Now it is certain, it is definitely a remote user, and it
    # either needs to be created, or updated from fresh data

    fetch_user!
  rescue Webfinger::Error => e
    Rails.logger.debug { "Webfinger query for #{@uri} failed: #{e}" }
    raise unless @options[:suppress_errors]
  end

  private

  def process_options!(uri, options)
    @options = { suppress_errors: true }.merge(options)

    if uri.is_a?(User)
      @user = uri
      @username = @user.username
      @domain   = @user.domain
    else
      @username, @domain = uri.strip.gsub(/\A@/, '').split('@')
    end

    @uri = [@username, @domain].compact.join('@')
  end

  def process_webfinger!(uri)
    @webfinger                           = webfinger!("acct:#{uri}")
    confirmed_username, confirmed_domain = split_acct(@webfinger.subject)

    if confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
      @username = confirmed_username
      @domain   = confirmed_domain
      return
    end

    # user doesn't match, so it may have been redirected
    @webfinger         = webfinger!("acct:#{confirmed_username}@#{confirmed_domain}")
    @username, @domain = split_acct(@webfinger.subject)

    unless confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
      raise Webfinger::RedirectError,
            "Too many webfinger redirects for URI #{uri} (stopped at #{@username}@#{@domain})"
    end
  rescue Webfinger::GoneError
    @gone = true
  end

  def split_acct(acct)
    acct.delete_prefix('acct:').split('@')
  end

  def fetch_user!
    return unless activitypub_ready?

    with_redis_lock("resolve:#{@username}@#{@domain}") do
      @user = FetchRemoteUserService.new.call(actor_url, suppress_errors: @options[:suppress_errors])
    end

    @user
  end

  def webfinger_update_due?
    # return false if @options[:check_delivery_availability] && !DeliveryFailureTracker.available?(@domain)
    # return false if @options[:skip_webfinger]

    @options[:skip_cache] || @user.nil?
  end

  def activitypub_ready?
    ['application/activity+json',
     'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(@webfinger.link('self', 'type'))
  end

  def actor_url
    @actor_url ||= @webfinger.link('self', 'href')
  end
end
