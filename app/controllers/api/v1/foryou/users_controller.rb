class Api::V1::Foryou::UsersController < ApiController
  include MastodonHelper
  before_action :set_user_with_mammoth, only: %i[show]
  before_action :cast_params, only: %i[update]

  def create
    user = User.create_by_remote(acct_param)
    Rails.logger.debug user
    render json: user
  end

  # Simple list of all personalized mammoth users
  # TODO: paginate
  def index
    render json: personalized_users, each_serializer: SimpleUserSerializer
  end

  # User with Configuration
  # If User is not found. Create new Mammoth user.
  # Since only iOS Mammoth users will/can request their `/me`
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

  def set_user_with_mammoth
    username, domain = acct_param.split('@')
    @user = User.where(username:, domain:).first
    # If no user if found, create it
    @user = User.create_by_remote(acct_param) if @user.nil?

    # Otherwise ensure it's correct attribute is local
    # 'local' users are Mammoth users.
    # Only Mammoth users are able to make API calls
    if @user.local?
      @user
    else
      @user.update(local: true)
    end
  end

  # personalize users are Mammoth users that have had
  # their follows, and fedigraph generated and added.
  def personalized_users
    @users = User.where(personalize: true)
  end

  def acct_param
    params.require(:acct)
  end

  def for_you_params
    params.permit(
      :acct,
      :status,
      :curated_by_mammoth,
      :friends_of_friends,
      :from_your_channels,
      :your_follows,
      enabled_channels: []
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
