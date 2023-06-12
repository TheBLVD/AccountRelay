class ApiController < ActionController::API
  before_action :authenticate_request
  attr_reader :current_instance

  private

  def authenticate_request
    @current_instance = AuthorizeApiRequestService.new.call(request.headers)
    render json: { error: 'Not Authorized' }, status: 401 unless @current_instance
  end
end
