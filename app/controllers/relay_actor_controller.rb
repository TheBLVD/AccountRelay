class RelayActorController < ApiController
  skip_before_action :authenticate_request
  @relay = 'https://acctrelay.moth.social'
  def show
    Rails.logger.info '>>>>>>'
    Rails.logger.info '#{requst.url}'
    Rails.logger.info "GET relay_actor request: #{params.inspect}"
    render json: {}, content_type: 'application/activity+json; charset=utf-8'
  end

  private

  def actor_payload
    {
      "@context": [
        'https://www.w3.org/ns/activitystreams',
        'https://w3id.org/security/v1'
      ],

      "id": 'https://my-example.com/actor',
      "type": 'Person',
      "preferredUsername": 'alice',
      "inbox": 'https://my-example.com/inbox',

      "publicKey": {
        "id": 'https://my-example.com/actor#main-key',
        "owner": 'https://my-example.com/actor',
        "publicKeyPem": '-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----'
      }
    }
  end
end
