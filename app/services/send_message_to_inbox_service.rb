# frozen_string_literal: true

# Given a paylaod this will provide a signature
# and POST that payload to the target inbox
class SendMessageToInboxService < BaseService
  HEADERS = { 'Content-Type' => 'application/activity+json' }.freeze
  class Error < StandardError; end

  def call(target_host, content)
    @target_host = target_host
    @content = content.to_json

    post_message_to_inbox
  end

  def post_message_to_inbox
    build_post_request(@target_host).perform do |response|
      Rails.logger.debug response.inspect

      body_to_json(response.body_with_limit) if response.code == 200
    end
  end

  def build_post_request(uri)
    Request.new(:post, uri, body: @content).tap do |request|
      # request.on_behalf_of(@source_account, sign_with: @options[:sign_with])
      request.add_headers(HEADERS)
    end
  end
end
