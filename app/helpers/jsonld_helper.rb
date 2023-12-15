# frozen_string_literal: true

module JsonldHelper
  include ContextHelper

  def equals_or_includes?(haystack, needle)
    haystack.is_a?(Array) ? haystack.include?(needle) : haystack == needle
  end

  def equals_or_includes_any?(haystack, needles)
    needles.any? { |needle| equals_or_includes?(haystack, needle) }
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

    build_request(uri, on_behalf_of).perform do |response|
      unless response_successful?(response) || response_error_unsalvageable?(response) || !raise_on_temporary_error
        raise AccountRelay::UnexpectedResponseError,
              response
      end

      body_to_json(response.body_with_limit) if response.code == 200
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

  def build_request(uri, on_behalf_of = nil)
    Request.new(:get, uri).tap do |request|
      request.on_behalf_of(on_behalf_of) if on_behalf_of
      request.add_headers('Accept' => 'application/activity+json, application/ld+json')
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
