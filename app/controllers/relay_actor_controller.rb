class RelayActorController < ApiController
  skip_before_action :authenticate_request
  @relay = "https://#{ENV.fetch('DOMAIN', nil)}"
  def show
    Rails.logger.info '>>>>>>'
    Rails.logger.info request.fullpath
    Rails.logger.info "GET relay_actor request: #{params.inspect}"
    render json: actor_payload, content_type: 'application/activity+json; charset=utf-8'
  end

  private

  def actor_payload
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      endpoints: {
        sharedInbox: "#{@relay}/inbox"
      },
      followers: "#{@relay}/followers",
      following: "#{@relay}/following",
      inbox: "#{@relay}/inbox",
      name: 'AcctRelay',
      type: 'Application',
      id: "#{@relay}/actor",
      publicKey: {
        id: "#{@relay}/actor#main-key",
        owner: "#{@relay}/actor",
        publicKeyPem: ENV.fetch('PUBLIC_KEY', nil)
      },
      summary: 'AcctRelay',
      preferredUsername: 'relay',
      url: "#{@relay}/actor"
    }
  end
end
