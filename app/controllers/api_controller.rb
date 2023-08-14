class ApiController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_instance

  DEFAULT_USERS_LIMIT = 80

  private

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    not_found
  end

  def authenticate_request
    @current_instance = AuthorizeApiRequestService.new.call(request.headers)
    render json: { error: 'Not Authorized' }, status: 401 unless @current_instance
  end

  def not_found
    respond_with_error(404)
  end

  def respond_with_error(code)
    render json: { error: Rack::Utils::HTTP_STATUS_CODES[code] }, status: code
  end
end
