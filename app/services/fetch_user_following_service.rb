# frozen_string_literal: true

# Given an user fetch their following
# for each following create association
class FetchUserFollowingService < BaseService
  include MastodonHelper
  def call(user, options = {})
    @user = user if user.is_a?(User)
    Rails.logger.info "OPTIONS: >>>> #{options}"
    fetch_following!
  end

  private

  #   User.find_or_create_by(username: account.username, domain: account.domain, discoverable: account.discoverable,
  #     display_name: account.display_name, domain_id: account.domain_id, followers_count: account.followers_count, following_count: account.following_count, local: true)

  # For a given user, get all the users they are following
  # Create that user if they do not exist
  # add association as following
  def fetch_following!
    direct_follows = direct_follows(@user)
    Rails.logger.debug "DIRECT_FOLLOWS OF #{@user.username}@#{@user.domain}"
    direct_follows.each do |follows|
      user = user_from_follow(follows)
      Rails.logger.debug "USER?: #{user.inspect}"
      return if user.nil?

      @user.follow!(user)
    end
  end
end

def user_from_follow(follow)
  # create/get User
  Rails.logger.debug "FOLLOWS?: #{follow}"
  follow['domain'] = URI.parse(follow.url).host
  remote_account = remote_account("#{follow.username}@#{follow.domain}")
  return if remote_account.nil?

  follows_user = User.where(username: follow.username,
                            domain: follow.domain).first
  # Patch
  follows_user&.update(domain_id: remote_account.domain_id)

  follows_user || User.create(username: remote_account.username, domain: remote_account.domain) do |user|
    user.discoverable = remote_account.discoverable
    user.display_name = remote_account.display_name
    user.domain_id = remote_account.domain_id
    user.domain = remote_account.domain
    user.followers_count = remote_account.followers_count
    user.following_count = remote_account.following_count
  end
end
