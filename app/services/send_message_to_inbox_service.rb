# frozen_string_literal: true

# Given a paylaod this will provide a signature
# and POST that payload to the target inbox
class SendMessageToInboxService < BaseService
  @relay = 'https://acctrelay.moth.social'
  class Error < StandardError; end

  def call(target_host, content)
    @target_host = target_host
    @content = content.to_json

    post_message_to_inbox
  end

  def post_message_to_inbox
    date = Time.now.utc.httpdate
    keypair       = OpenSSL::PKey::RSA.new(ENV['PRIVATE_KEY'])
    signed_string = "(request-target): post /inbox\nhost: #{@target_host}\ndate: #{date}"
    signature     = Base64.strict_encode64(keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))
    header        = "keyId=\"https://acctrelay.moth.social/actor\",headers=\"(request-target) host date\",signature=\"#{signature}\""

    Rails.logger.info "CONTENT: #{@content}"
    Rails.logger.info "TARGET_HOST: #{@target_host}"

    Rails.logger.info "Header #{header}"
    HTTP.headers({ 'Host': @relay.to_s, 'Date': date, 'Signature': header, 'Content-Type': 'application/activity+json' })
        .post("#{@target_host}/inbox", body: @content.to_s)
  end
end
