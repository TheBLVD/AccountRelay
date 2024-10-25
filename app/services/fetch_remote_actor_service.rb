# frozen_string_literal: true

class FetchRemoteActorService < BaseService
  include JsonldHelper
  include WebfingerHelper

  class Error < StandardError; end

  SUPPORTED_TYPES = %w[Application Group Organization Person Service].freeze

  def call(uri, id: true, prefetched_body: nil, break_on_redirect: false, only_key: false, suppress_errors: true,
           request_id: nil)
    if uri.is_a?(User)
      @user = uri
      @username = @user.username
      @domain   = @user.domain
    else
      Rails.logger.info "FetchRemoteActorService: #{uri}"
    end

    @json = begin
      Rails.logger.info "FetchRemoteActorService L22: #{uri}"
      fetch_resource(uri, id)
    rescue Oj::ParseError
      raise Error, "Error parsing JSON-LD document #{uri}"
    end

    raise Error, "Error fetching actor JSON at #{uri}" if @json.nil?
    raise Error, "Unexpected object type for actor #{uri} (expected any of: #{SUPPORTED_TYPES})" unless expected_type?
    raise Error, "Actor #{uri} has moved to #{@json['movedTo']}" if break_on_redirect && @json['movedTo'].present?

    if @json['preferredUsername'].blank?
      raise Error,
            "Actor #{uri} has no 'preferredUsername', which is a requirement for Mastodon compatibility"
    end

    @uri      = @json['id']
    @username = @json['preferredUsername']
    @domain   = Addressable::URI.parse(@uri).normalized_host

    check_webfinger!

    ProcessUserService.new.call(@username, @domain, @json, only_key:, verified_webfinger: !only_key,
                                                           request_id:)
  rescue Error => e
    Rails.logger.info do
      "Fetching actor #{uri} failed: #{e.message}"
    end
    raise unless suppress_errors
  end

  private

  def check_webfinger!
    Rails.logger.info "Checking webfinger >> #{@username} : #{@domain}"
    webfinger                            = webfinger!("acct:#{@username}@#{@domain}")
    confirmed_username, confirmed_domain = split_acct(webfinger.subject)

    if @username.casecmp(confirmed_username).zero? && @domain.casecmp(confirmed_domain).zero?
      raise Error, "Webfinger response for #{@username}@#{@domain} does not loop back to #{@uri}" if webfinger.link(
        'self', 'href'
      ) != @uri

      return
    end

    webfinger = webfinger!("acct:#{confirmed_username}@#{confirmed_domain}")
    @username, @domain = split_acct(webfinger.subject)

    unless confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
      raise Webfinger::RedirectError,
            "Too many webfinger redirects for URI #{@uri} (stopped at #{@username}@#{@domain})"
    end

    raise Error, "Webfinger response for #{@username}@#{@domain} does not loop back to #{@uri}" if webfinger.link(
      'self', 'href'
    ) != @uri
  rescue Webfinger::RedirectError => e
    raise Error, e.message
  rescue Webfinger::Error => e
    raise Error, "Webfinger error when resolving #{@username}@#{@domain}: #{e.message}"
  end

  def split_acct(acct)
    acct.gsub(/\Aacct:/, '').split('@')
  end

  def supported_context?
    super(@json)
  end

  def expected_type?
    equals_or_includes_any?(@json['type'], SUPPORTED_TYPES)
  end
end
