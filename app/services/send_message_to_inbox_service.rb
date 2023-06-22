# frozen_string_literal: true

# Given a paylaod this will provide a signature
# and POST that payload to the target inbox
class SendMessageToInboxService < BaseService
  @relay = 'https://acctrelay.moth.social'
  class Error < StandardError; end

  def call(target_host, content)
    @target_host = target_host
    @content = content

    post_message_to_inbox
  end

  def post_message_to_inbox
    sha256 = OpenSSL::Digest.new('SHA256')
    digest = 'SHA-256=' + Base64.strict_encode64(sha256.digest(@content.to_s))

    date = Time.now.utc.httpdate
    keypair       = OpenSSL::PKey::RSA.new(ENV['PRIVATE_KEY'])
    signed_string = "(request-target):\nhost: #{@target_host}\ndate: #{date}\ndigest: #{digest}\ncontent-type: 'application/activity+json'"
    signature     = Base64.strict_encode64(keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))
    header        = "keyId=\"https://acctrelay.moth.social/actor#main-key\", algorithm=\"rsa-sha256\", headers=\"(request-target) host date digest content-type\", signature=\"#{signature}\""

    Rails.logger.info "CONTENT: #{@content}"
    Rails.logger.info "TARGET_HOST: #{@target_host}"
    Rails.logger.info "SHA256: #{sha256}"
    Rails.logger.info "DIGEST HEADER: #{digest}"
    Rails.logger.info "SIGNED_STRING: #{signed_string}"
    Rails.logger.info "Header #{header}"

    response = HTTP.headers({ 'host': 'staging.moth.social', 'date': date, 'signature': header, 'digest': digest, 'Content-Type': 'application/activity+json' }).post(
      'https://staging.moth.social/inbox', json: @content
    )

    Rails.logger.info "RESPONSE:>>>> #{response.status}"
    Rails.logger.info "RESPONSE_BODY:>>>> #{response.body}"
    Rails.logger.info response.inspect
    response
  end
end
