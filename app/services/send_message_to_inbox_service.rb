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
  # var digest = CryptographyHelper.GetSHA256Digest(content);
  # var requestContent = new StringContent(content);

  # requestContent.Headers.Add("Digest", "SHA-256=" + digest);

  # var stringToSign = $"(request-target): post /inbox\ndate: {date.ToString("R")}\nhost: {targetHost}\ndigest: SHA-256={digest}\ncontent-length: {content.Length}";
  # var signature = CryptographyHelper.Sign(stringToSign);
  # requestContent.Headers.Add("Signature", $@"keyId=""https://{Config.Instance.Host}/actor#main-key"",algorithm=""rsa-sha256"",headers=""(request-target) date host digest content-length"",signature=""{signature}""");

  def post_message_to_inbox
    sha256 = OpenSSL::Digest.new('SHA256')
    digest = 'SHA-256=' + Base64.strict_encode64(sha256.digest(@content.to_s))

    date = Time.now.utc.httpdate
    keypair       = OpenSSL::PKey::RSA.new(ENV['PRIVATE_KEY'])
    signed_string = "(request-target): post /inbox\nhost: #{@target_host}\ndate: #{date}\ndigest: #{digest}"
    signature     = Base64.strict_encode64(keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))
    header        = "keyId=\"https://acctrelay.moth.social/actor#main-key\",headers=\"(request-target) host date\",signature=\"#{signature}\""

    Rails.logger.info "CONTENT: #{@content}"
    Rails.logger.info "TARGET_HOST: #{@target_host}"
    Rails.logger.info "DIGEST HEADER: #{digest}"
    Rails.logger.info "SIGNED_STRING: #{signed_string}"

    # HTTP.headers({ 'Host': 'mastodon.social', 'Date': date, 'Signature': header })
    #     .post('https://mastodon.social/inbox', body: document)
    # { 'Host': @relay.to_s, 'Date': date, 'Signature': header, 'Content-Type': 'application/activity+json' }
    Rails.logger.info "Header #{header}"

    response = HTTP.headers({ 'Host': 'staging.moth.social', 'Date': date, 'Signature': header, 'Digest': digest }).post(
      'https://staging.moth.social/inbox', json: @content
    )

    Rails.logger.info "RESPONSE:>>>> #{response.status}"
    Rails.logger.info "RESPONSE_BODY:>>>> #{response.body}"
    Rails.logger.info response.inspect
    response
  end
end
