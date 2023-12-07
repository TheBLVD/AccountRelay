class Api::V1::ChannelsController < ApiController
  before_action :set_channel, except: %i[index accounts]
  before_action :set_user, only: %i[subscribe unsubscribe]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  rescue_from ActiveRecord::RecordNotFound do |_exception|
    Rails.logger.warn "Channel not found: #{params[:id]}"
    render json: { error: "Channel #{params[:id]} not found" }, status: 404
  end

  def index
    @channels = Channel.where(hidden: false).all
    render json: @channels, each_serializer: SimpleChannelSerializer, show_accounts: channel_accounts_param
  end

  def show
    render json: @channel, serializer: ChannelSerializer
  end

  def subscribe
    SubscribeService.new.call(@user, @channel)

    render json: @user, serializer: AdvanceUserSerializer
  end

  def unsubscribe
    UnsubscribeService.new.call(@user, unsubscribe_channel)

    render json: @user, serializer: AdvanceUserSerializer
  end

  def accounts
    @accounts = channel_accounts
    render json: @accounts
  end

  private

  def channel_accounts
    ChannelAccount.all.includes(:user).pluck(:username, :domain).map do |username, domain|
      { username:, domain: }
    end
  end

  def set_channel
    @channel = Channel.where(hidden: false).find(params[:id])
  end

  # When unsubscribing, this might happen from a hidden channel
  # We need to beable to trigger this. Even after hiding/depracating a channel
  def unsubscribe_channel
    Channel.find(params[:id])
  end

  def set_user
    clear_user_cache
    @user = User.by_handle(acct_param)
  end

  def acct_param
    params.require(:acct)
  end

  def clear_user_cache
    username, domain = acct_param.split('@')
    Rails.cache.delete("user:show:#{username}:#{domain}")
  end

  def channel_accounts_param
    Rails.logger.debug "PARAM #{params.permit(:include_accounts)}"
    params[:include_accounts].to_s.eql?('true')
  end
end
