class AuthorizeApiRequestService < BaseService
  def call(headers = {})
    @headers = headers
    instance
  end

  private

  attr_reader :headers

  def instance
    @instance ||= Instance.find_by(key: bearer_token) if bearer_token
    @instance || nil
  end

  def bearer_token
    pattern = /^Bearer /
    header  = @headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end
end
