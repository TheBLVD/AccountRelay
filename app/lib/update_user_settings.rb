class UpdateUserSettings
  def initialize(params)
    @params = params
    @user   = user
  end

  def call
    iterate_params
    @user.save!
    @user
  end

  private

  def user
    username, domain = @params['acct'].split('@')

    User.where(username:, domain:).first
  end

  def iterate_params
    # Deprecated. assign type to 'personal'
    @user.for_you_settings['type'] = 'personal'
    @params.except('acct').each do |key1, value1|
      Rails.logger.debug "#{key1} :: #{value1}"
      @user.for_you_settings[key1] = (value1 || @user.for_you_settings[key1])
    end
  end
end