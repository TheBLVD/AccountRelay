class RelayInboxController < ApiController
  skip_before_action :authenticate_request
  before_action :require_follow_type!

  def create
    @host = params['actor']
    @relay = "https://#{ENV.fetch('DOMAIN', nil)}"
    @id = params['id']
    SendMessageToInboxService.new.call(@host, instance_follow)
    render json: instance_follow, content_type: 'application/activity+json'
  end

  def require_follow_type!
    render json: {}, content_type: 'application/activity+json' unless params['type'] == 'Follow'
  end

  def instance_follow
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
        'https://w3id.org/security/v1'
      ],
      actor: "#{@relay}/actor",
      id: "#{@relay}/activities/#{SecureRandom.uuid}",
      type: 'Accept',
      object: {
        type: 'Follow',
        actor: @host.to_s,
        object: "#{@relay}/actor",
        id: @id.to_s
      },
      to: [
        @host.to_s
      ]
    }
  end
end
