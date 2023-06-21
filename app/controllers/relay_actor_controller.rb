class RelayActorController < ApiController
  skip_before_action :authenticate_request
  def show
    Rails.logger.info '>>>>>>'
    Rails.logger.info '#{requst.url}'
    Rails.logger.info "GET relay_actor request: #{params.inspect}"
    render json: {}, content_type: 'application/activity+json; charset=utf-8'
  end

  private

  def actor_url
    request.url
  end
end
