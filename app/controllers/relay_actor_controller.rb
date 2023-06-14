class RelayActorController < ApiController
  skip_before_action :authenticate_request
  def show
    @host = 'http://localhost:3000'
    @relay = 'https://7ad1-71-209-214-147.ngrok-free.app'
    Rails.logger.debug '>>>>>>'
    Rails.logger.debug '#{requst.url}'
    Rails.logger.debug "GET relay_actor request: #{params.inspect}"
    render json: {}, content_type: 'application/activity+json; charset=utf-8'
  end

  private


  def actor_url
    request.url
  end
end
