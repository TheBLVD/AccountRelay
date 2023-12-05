# [GET] "/api/v1/admin/users"
# /api/v1/admin/users
# Returns a paginated array of all 'Active Mammoth Users'

class Api::V1::Admin::UsersController < ApiController
  include Pagy::Backend
  after_action { pagy_headers_merge(@pagy) if @pagy }

  def index
    @pagy, @users = pagy(User.where(local: true))
    render json: @users, each_serializer: SimpleUserSerializer
  end

  def update
    Rails.logger.debug "PARAMS #{acct_update_params}"
    Rails.logger.debug "PARAMS #{last_active_param}"
    username, domain = acct_update_params.split('@')
    user = User.where(username:, domain:).first
    user.update(last_active: last_active_param)
  end

  private

  def acct_update_params
    params.except(:format).require(:acct)
  end

  def last_active_param
    params.except(:format).require(:last_active).to_i
  end
end
