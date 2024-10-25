# frozen_string_literal: true

module JsonldHelper
  include ContextHelper

  ACCEPT_HEADER = 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'

  def equals_or_includes?(haystack, needle)
    haystack.is_a?(Array) ? haystack.include?(needle) : haystack == needle
  end

  def equals_or_includes_any?(haystack, needles)
    needles.any? { |needle| equals_or_includes?(haystack, needle) }
  end

  def first_of_value(value)
    value.is_a?(Array) ? value.first : value
  end

  def uri_from_bearcap(str)
    if str&.start_with?('bear:')
      Addressable::URI.parse(str).query_values['u']
    else
      str
    end
  end

  # The url attribute can be a string, an array of strings, or an array of objects.
  # The objects could include a mimeType. Not-included mimeType means it's text/html.
  def url_to_href(value, preferred_type = nil)
    single_value = if value.is_a?(Array) && !value.first.is_a?(String)
                     value.find do |link|
                       preferred_type.nil? || ((link['mimeType'].presence || 'text/html') == preferred_type)
                     end
                   elsif value.is_a?(Array)
                     value.first
                   else
                     value
                   end

    if single_value.nil? || single_value.is_a?(String)
      single_value
    else
      single_value['href']
    end
  end

  def as_array(value)
    if value.nil?
      []
    elsif value.is_a?(Array)
      value
    else
      [value]
    end
  end

  def fetch_resource(uri, id, on_behalf_of = nil)
    unless id
      json = fetch_resource_without_id_validation(uri, on_behalf_of)

      return if !json.is_a?(Hash) || unsupported_uri_scheme?(json['id'])

      uri = json['id']
    end

    json = fetch_resource_without_id_validation(uri, on_behalf_of)
    json.present? && json['id'] == uri ? json : nil
  end

  def fetch_resource_without_id_validation(uri, on_behalf_of = nil, raise_on_temporary_error = false)
    # on_behalf_of ||= User.representative
    Rails.logger.debug "FETCH RESOURCE: #{uri}"
    build_request(uri, on_behalf_of).perform do |response|
      unless response_successful?(response) || response_error_unsalvageable?(response) || !raise_on_temporary_error
        raise AccountRelay::UnexpectedResponseError,
              response
      end

      body_to_json(response.body.to_s) if response.code == 200
    end
  end

  def unsupported_uri_scheme?(uri)
    uri.nil? || !uri.start_with?('http://', 'https://')
  end

  def body_to_json(body, compare_id: nil)
    json = body.is_a?(String) ? Oj.load(body, mode: :strict) : body

    return if compare_id.present? && json['id'] != compare_id

    json
  rescue Oj::ParseError
    nil
  end

  def response_successful?(response)
    (200...300).cover?(response.code)
  end

  def response_error_unsalvageable?(response)
    response.code == 501 || ((400...500).cover?(response.code) && ![401, 408, 429].include?(response.code))
  end

  Actor = Struct.new(:uri)
  def build_request(uri, _on_behalf_of = nil)
    Request.new(:get, uri).tap do |request|
      aa = Actor.new("https://#{ENV.fetch('DOMAIN', nil)}")
      Rails.logger.debug "ACTOR>>>>> #{aa.uri}"
      Rails.logger.debug "HEADER>>>>> #{ACCEPT_HEADER}"
      request.on_behalf_of(Actor.new("https://#{ENV.fetch('DOMAIN', nil)}"),
                           sign_with: ENV.fetch('PRIVATE_KEY', nil))
      request.add_headers('Accept' => ACCEPT_HEADER)
    end
  end

  def load_jsonld_context(url, _options = {}, &block)
    json = Rails.cache.fetch("jsonld:context:#{url}", expires_in: 30.days, raw: true) do
      request = Request.new(:get, url)
      request.add_headers('Accept' => 'application/ld+json')
      request.perform do |res|
        unless res.code == 200 && res.mime_type == 'application/ld+json'
          raise JSON::LD::JsonLdError::LoadingDocumentFailed
        end

        res.body_with_limit
      end
    end

    doc = JSON::LD::API::RemoteDocument.new(json, documentUrl: url)

    block ? yield(doc) : doc
  end
end
