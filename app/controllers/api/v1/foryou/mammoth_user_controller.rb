# [GET] "/api/v1/foryou/users/jtomchak%40moth.social/mammoth"
# /api/v1/foryou/users/:user_acct/mammoth
# Returns true or false for a mammoth 2.0 account verses a regular account.

class Api::V1::Foryou::MammothUserController < ApiController
  def index
    render json: { acct: user_acct_param, mammoth_user: mammoth_user? }
  end

  private

  def mammoth_user?
    username, domain = user_acct_param.split('@')
    User.exists?(username:, domain:, local: true)
  end

  def user_acct_param
    params.require(:user_acct)
  end
end
