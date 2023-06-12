# frozen_string_literal: true

class FetchRemoteActorService < BaseService
  #   include JsonLdHelper
  include WebfingerHelper

  class Error < StandardError; end

  SUPPORTED_TYPES = %w[Application Group Organization Person Service].freeze

  def call(uri, _options = {})
    if uri.is_a?(Account)
      @account = uri
      @username = @account.username
      @domain   = @account.domain
    else
      @username, @domain = uri.strip.gsub(/\A@/, '').split('@')
    end

    check_webfinger!
  end

  private

  def check_webfinger!
    webfinger                            = webfinger!("acct:#{@username}@#{@domain}")
    confirmed_username, confirmed_domain = split_acct(webfinger.subject)

    if @username.casecmp(confirmed_username).zero? && @domain.casecmp(confirmed_domain).zero?
      raise Error, "Webfinger response for #{@username}@#{@domain} does not loop back to #{@uri}" if webfinger.link(
        'self', 'href'
      ) != @uri

      return
    end

    webfinger                            = webfinger!("acct:#{confirmed_username}@#{confirmed_domain}")
    @username, @domain                   = split_acct(webfinger.subject)

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
end
