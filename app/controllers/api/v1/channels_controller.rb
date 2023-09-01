class Api::V1::ChannelsController < ApiController
  before_action :set_channel, except: %i[index]
  before_action :set_user, only: %i[subscribe unsubscribe]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def index
    @channels = Channel.where(hidden: false).all
    render json: @channels, each_serializer: SimpleChannelSerializer
  end

  def show
    render json: @channel, serializer: ChannelSerializer
  end

  def subscribe
    SubscribeService.new.call(@user, @channel)

    render json: @user, serializer: AdvanceUserSerializer
  end

  def unsubscribe
    UnsubscribeService.new.call(@user, @channel)

    render json: @user, serializer: AdvanceUserSerializer
  end

  private

  def set_channel
    @channel = Channel.where(hidden: false).find(params[:id])
  end

  def set_user
    @user = User.by_handle(acct_param)
  end

  def acct_param
    params.require(:acct)
  end
end
