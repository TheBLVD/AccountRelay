# [GET] "/api/v1/admin/users"
# /api/v1/admin/users
# Returns a paginated array of all 'Active Mammoth Users'

class Api::V1::Admin::UsersController < ApiController
  include Pagy::Backend
  after_action { pagy_headers_merge(@pagy) if @pagy }

  THROTTLE_LIMIT = ENV['THROTTLE_LIMIT'] || 30_000
  USERS_PER_PAGE = 500

  def index
    @pagy, @users = pagy(mammoth_users, items:USERS_PER_PAGE )
    render json: @users, each_serializer: SimpleUserSerializer
  end

  def update
    username, domain = acct_update_params.split('@')
    user = User.where(username:, domain:).first
    user.update(last_active: last_active_param)
  end

  private

  def mammoth_users
    Rails.logger.warn "THROTTLE_LIMIT: #{THROTTLE_LIMIT}"
    User.where(local: true).order(last_active: :asc).limit(THROTTLE_LIMIT)
  end

  def acct_update_params
    params.except(:format).require(:acct)
  end

  def last_active_param
    params.except(:format).require(:last_active).to_i
  end
end
