class Api::V1::AccountsController < ApiController
  def index; end

  def create
    render json: params
  end

  def destroy; end
end
