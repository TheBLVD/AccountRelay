class Api::V1::ChannelsController < ApiController
  before_action :set_channel, except: %i[index create]

  rescue_from ArgumentError do |e|
    render json: { error: e.to_s }, status: 422
  end

  def index
    @channels = Channel.where(hidden: false).all
    render json: @channels, each_serializer: ChannelSerializer
  end

  def show
    render json: @channel, serializer: ChannelSerializer
  end

  def new; end

  def destory; end

  def set_channel
    @channel = Channel.where(hidden: false).find(params[:id])
  end
end
