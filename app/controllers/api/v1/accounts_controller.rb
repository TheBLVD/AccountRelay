class Api::V1::AccountsController < ApiController
  def index; end

  def create
    account_records = generate_account_records
    begin
      Instance.transaction do
        @accounts = @current_instance.accounts.create(account_records)
      end
    rescue ActiveRecord::RecordInvalid => e
      # omitting the exception type rescues all StandardErrors
      @accounts = {
        error: {
          status: 422,
          message: e
        }
      }
    end
    render json: @accounts
  end

  def destroy; end

  private

  # From the list of accounts
  # create a record of each with need attributes
  def generate_account_records
    params['accounts'].map do |account|
      username, domain = account.split('@')
      {
        username:,
        domain:,
        handle: account,
        owner: params['owner']
      }
    end
  end
end
