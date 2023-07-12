# frozen_string_literal: true

# Given a paylaod this will provide a signature
# and POST that payload to the target inbox
class SendMessageToInboxService < BaseService
  class Error < StandardError; end

  def call(target, content)
    @target_uri = URI.parse(target)
    @content = content

    post_message_to_inbox
  end

  def post_message_to_inbox
    @relay = 'https://acctrelay.moth.social'
    target_host = @target_uri.host
    sha256 = OpenSSL::Digest.new('SHA256')
    digest = 'SHA-256=' + Base64.strict_encode64(sha256.digest(@content.to_json))

    date          = Time.now.utc.httpdate
    keypair       = OpenSSL::PKey::RSA.new(ENV['PRIVATE_KEY'])
    signed_string = "(request-target): post /inbox\nhost: #{target_host}\ndate: #{date}\ndigest: #{digest}"
    signature     = Base64.strict_encode64(keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))
    header        = "keyId=\"#{@relay}/actor#main-key\", headers=\"(request-target) host date digest\",signature=\"#{signature}\""

    response = HTTP.headers({ 'host': target_host, 'date': date, 'signature': header, 'digest': digest, 'Content-Type': 'application/activity+json' }).post(
      "https://#{target_host}/inbox", json: @content
    )

    # Logging is back :wink:
    Rails.logger.info "RESPONSE:>>>> #{response.status}"
    # Rails.logger.info "RESPONSE_BODY:>>>> #{response.body}"
    Rails.logger.info response.inspect
    response
  end
end
