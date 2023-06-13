# frozen_string_literal: true

module JsonldHelper
  include ContextHelper
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
    on_behalf_of ||= Account.representative

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

  def build_request(uri, on_behalf_of = nil)
    Request.new(:get, uri).tap do |request|
      request.on_behalf_of(on_behalf_of) if on_behalf_of
      request.add_headers('Accept' => 'application/activity+json, application/ld+json')
    end
  end
end
