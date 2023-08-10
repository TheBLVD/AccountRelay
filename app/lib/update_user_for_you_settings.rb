class UpdateUserForYouSettings
  def initialize(params)
    @params = params
    @user   = user
  end

  def call
    iterate_params
    @user.save!
  end

  private

  def user
    username, domain = @params[:acct].split('@')
    User.where(username:, domain:)
  end

  def iterate_params
    params = @params.delete(:acct)
    params.each do |key1, value1|
      @user.for_you_settings[key1] = (value1 || @user.for_you_settings[key1])
    end
  end
end
