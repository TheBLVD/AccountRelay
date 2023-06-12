# frozen_string_literal: true

class FetchRemoteStatusesService < BaseService
  def call(account, options = {})
    @account = account
    @options = options
  end
end
