class Api::V1::AccountsController < ApiController
  def index; end

  def create
    account_records = generate_account_records
    render json: @current_instance.accounts.create(account_records)
  end

  def destroy; end

  private

  def generate_account_records
    params['accounts'].map do |account|
      username, domain = account.split('@')
      {
        username:,
        domain:,
        owner: params['owner']
      }
    end
  end
end
