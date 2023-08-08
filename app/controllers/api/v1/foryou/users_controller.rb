class Api::V1::Foryou::UsersController < ApiController
  include MastodonHelper
  def index; end

  def create
    user = create_user
    Rails.logger.debug user
    render json: user
  end

  # Simple list of all mammoth users
  def index
    render json: local_users, each_serializer: SimpleUserSerializer
  end

  # User with Configuration
  def show
    username, domain = acct_param.split('@')
    user = User.where(username:, domain:).first
    render json: user, serializer: ::SimpleUserSerializer
  end

  def destroy; end

  private

  # Create user if it doesn't exist
  # If it does we want to mark it as a Mammoth Account
  def create_user
    account = remote_account(acct_param)
    User.find_or_create_by(username: account.username, domain: account.domain, discoverable: account.discoverable,
                           display_name: account.display_name, domain_id: account.domain_id, followers_count: account.followers_count, following_count: account.following_count, local: true)
  end

  def local_users
    @users = User.where(local: true)
  end

  def acct_param
    params.require(:acct)
  end
end
