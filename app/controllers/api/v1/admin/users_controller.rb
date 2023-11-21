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
end
