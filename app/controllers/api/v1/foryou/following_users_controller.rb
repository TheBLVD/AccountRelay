# [GET] "/api/v1/foryou/users/jtomchak%40moth.social/following"
# /api/v1/foryou/users/:user_acct/following

class Api::V1::Foryou::FollowingUsersController < ApiController
  before_action :set_user

  def index
    render json: @user
  end

  private

  def set_user
    username, domain = user_acct_param.split('@')
    @user = User.where(username:, domain:).first
  end

  def load_users
    scope = default_users
    scope.merge(paginated_follows).to_a
  end

  def default_users
    User.includes(:active_relationships).references(:active_relationships)
  end

  # currently returning all
  def paginated_follows
    Follow.where(user: @user)
  end

  def user_acct_param
    params.require(:user_acct)
  end
end
