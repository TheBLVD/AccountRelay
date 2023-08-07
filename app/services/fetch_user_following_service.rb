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
      @user.follow!(user)
    end
  end
end

def user_from_follow(follows)
  # create/get User
  Rails.logger.debug "FOLLOWS?: #{follows}"
  follows['domain'] = URI.parse(follows.url).host
  follows_user = User.where(username: follows.username, domain: follows.domain).first

  follows_user || User.create(username: follows.username, domain: follows.domain) do |user|
    user.discoverable = follows.discoverable
    user.display_name = follows.display_name
    user.domain_id = follows.id
    user.domain = follows.domain
    user.followers_count = follows.followers_count
    user.following_count = follows.following_count
  end
end
