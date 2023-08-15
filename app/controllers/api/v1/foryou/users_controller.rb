class Api::V1::Foryou::UsersController < ApiController
  include MastodonHelper
  before_action :set_user, only: %i[show]
  before_action :cast_params, only: %i[update]

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
    render json: @user, serializer: AdvanceUserSerializer
  end

  # User Configuration
  def update
    Rails.logger.debug "PARAMS: #{for_you_params}"
    user = UpdateUserSettings.new(for_you_params).call
    Rails.logger.debug user

    render json: user, serializer: AdvanceUserSerializer
  end

  def destroy; end

  private

  def set_user
    username, domain = acct_param.split('@')
    @user = User.where(username:, domain:).first!
  end

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

  def for_you_params
    params.permit(
      :acct,
      :curated_by_mammoth,
      :friends_of_friends,
      :from_your_channels,
      :your_follows
    )
  end

  # If follow params are present cast to integer, otherwise nil
  def cast_params
    params[:curated_by_mammoth] = params[:curated_by_mammoth].present? ? params[:curated_by_mammoth].to_i : nil
    params[:friends_of_friends]  = params[:friends_of_friends].present? ? params[:friends_of_friends].to_i : nil
    params[:from_your_channels]  = params[:from_your_channels].present? ? params[:from_your_channels].to_i : nil
    params[:your_follows] = params[:your_follows].present? ? params[:your_follows].to_i : nil
  end
end
