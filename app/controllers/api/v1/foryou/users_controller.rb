class Api::V1::Foryou::UsersController < ApiController
  include MastodonAccountHelper
  def index; end

  def create
    user = create_user
    Rails.logger.debug user
    render json: user
  end

  def show
    render json: { "type": 'hello' }
  end

  def destroy; end

  private

  # Create user if it doesn't exist
  # If it does we want to mark it as a Mammoth Account
  def create_user
    account = remote_account(acct_param)
    User.find_or_create_by(username: account.username, domain: account.domain, discoverable: account.discoverable,
                           display_name: account.display_name, domain_id: account.domain_id, followers_count: account.followers_count, following_count: account.following_count)
  end

  def acct_param
    params.require(:acct)
  end
end
