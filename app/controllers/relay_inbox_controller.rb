class RelayInboxController < ApiController
  skip_before_action :authenticate_request
  before_action :require_follow_type!

  def create
    @host = params['actor']
    @relay = 'https://7ad1-71-209-214-147.ngrok-free.app'
    Rails.logger.debug '>>>>>>'
    Rails.logger.debug "#{request.host_with_port}#{request.fullpath}"
    SendMessageToInboxService.new.call(@host, instance_follow)
    render json: instance_follow, content_type: 'application/activity+json'
  end

  def require_follow_type!
    render json: {}, content_type: 'application/activity+json' unless params['type'] == 'Follow'
  end

  def instance_follow
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      'type': 'Accept',
      'to': [@host.to_s],
      'actor': "#{@relay}/actor",
      'object': {
        'type': 'Follow',
        'actor': @host.to_s,
        'id': "#{@relay}/activities/#{SecureRandom.uuid}"
      }
    }
  end
end
