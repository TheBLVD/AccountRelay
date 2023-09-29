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
    Rails.logger.debug "USER UPDATING SETTINGS>> #{@user.inspect}"
    iterate_enabled_channels
    @params.except('acct', 'enabled_channels').each do |key1, value1|
      @user.for_you_settings[key1] = (value1 || @user.for_you_settings[key1])
    end
  end

  # If false is sent, then it needs to be assigned to an empty array. No selections.
  # It would default to the user's subscribed channels if the
  # key value isn't present
  def iterate_enabled_channels
    return unless @params['enabled_channels']

    @user.for_you_settings['enabled_channels'] = if @params['enabled_channels'][0] == 'false'
                                                   []
                                                 else
                                                   @params['enabled_channels']
                                                 end
  end
end
