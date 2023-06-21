class RelayActorController < ApiController
  skip_before_action :authenticate_request
  @relay = 'https://acctrelay.moth.social'
  def show
    Rails.logger.info '>>>>>>'
    Rails.logger.info request.fullpath
    Rails.logger.info "GET relay_actor request: #{params.inspect}"
    render json: actor_payload, content_type: 'application/activity+json; charset=utf-8'
  end

  private

  def actor_payload
    {
      "@context": 'https://www.w3.org/ns/activitystreams',
      "endpoints": {
        "sharedInbox": 'https://acctrelay.moth.social/inbox'
      },
      "followers": 'https://acctrelay.moth.social/followers',
      "following": 'https://acctrelay.moth.social/following',
      "inbox": 'https://acctrelay.moth.social/inbox',
      "name": 'AcctRelay',
      "type": 'Application',
      "id": 'https://acctrelay.moth.social/actor',
      "publicKey": {
        "id": 'https://acctrelay.moth.social/actor#main-key',
        "owner": 'https://acctrelay.moth.social/actor',
        "publicKeyPem": ENV['PUBLIC_KEY']
      },
      "summary": 'AcctRelay',
      "preferredUsername": 'relay',
      "url": 'https://acctrelay.moth.social/actor'
    }
  end
end
