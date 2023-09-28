# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                            :bigint(8)        not null, primary key
#  username                      :string           default(""), not null
#  domain                        :string           default(""), not null
#  display_name                  :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  discoverable                  :boolean
#  domain_id                     :string           user id from their domain instance
#  followers_count               :int              number of user's following this user
#  following_count               :int              number of user's they are following
#  local                         :boolean          a local account was created via the api. considered a Mammoth user.
#  personalize                   :boolean          Mammoth account has updated with personaliztion. ie generated follows/fedigraph

class User < ApplicationRecord
  include AcctHandle

  serialize :for_you_settings, JsonbSerializers
  store_accessor :curated_by_mammoth, :friends_of_friends, :from_your_channels, :your_follows, :status,
                 :enabled_channels

  FOR_YOU_SETTINGS_SCHEMA = Rails.root.join('app', 'models', 'schemas', 'user_for_you_settings.json')
  validates :for_you_settings, presence: true, if: :local?, json: { message: lambda { |errors|
                                                                               errors
                                                                             }, schema: FOR_YOU_SETTINGS_SCHEMA }
  validates :username, uniqueness: { scope: :domain }

  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'user_id',        dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_user_id', dependent: :destroy

  has_many :passive_channels, class_name: 'ChannelAccount', foreign_key: 'user_id', dependent: :destroy
  has_many :active_channels, class_name: 'Subscribe', foreign_key: 'user_id', dependent: :destroy

  has_many :following, -> { order('follows.id desc') }, through: :active_relationships,  source: :target_user
  has_many :followers, -> { order('follows.id desc') }, through: :passive_relationships, source: :user

  has_many :subscribes, lambda {
                          order('subscribes.id desc')
                        }, through: :active_channels, source: :channel

  after_initialize :set_defaults
  before_validation :set_defaults

  # Add user as a following
  def follow!(other_user)
    rel = active_relationships.find_or_create_by!(target_user: other_user)
    Rails.logger.debug "SAVE_FOLLOW:: HAS_CHANGED:: #{rel.changed?}"
    rel.save! if rel.changed?

    rel
  end

  # Remove user from following
  def unfollow!(other_user)
    follow = active_relationships.find_by(target_user: other_user)
    follow&.destroy
  end

  # Add channel to user's subscribes relationship
  # By Default the channel is also added to 'enabled_channels' ForYou Settings
  def subscribe!(channel)
    rel = active_channels.find_or_create_by!(channel:)
    updated_enabled_channels = for_you_settings[:enabled_channels].to_set.add(channel[:id])
    for_you_settings[:enabled_channels] = updated_enabled_channels.to_a

    rel.save!
    save!
  end

  # Remove channel to user's subscribes relationship
  def unsubscribe!(channel)
    subscribe = active_channels.find_or_create_by!(channel:)
    for_you_settings[:enabled_channels] = for_you_settings[:enabled_channels].filter { |c| c != channel[:id] }

    subscribe&.destroy
    save!
  end

  def acct
    "#{username}@#{domain}"
  end

  # Settings will be off, low, med, high
  # So the enum 0-3 to match
  # hash[:key] = 0 unless hash.has_key?(:key)
  def set_defaults
    Rails.logger.debug 'SETTING DEFAULTS'
    for_you_settings[:type] = personalize? ? 'personal' : 'public'
    return unless local? # early return if user is not a Mammoth user

    # For You Status Of
    for_you_settings[:status] = 'idle' unless for_you_settings.key?(:status)

    # For You Channels Selected
    for_you_settings[:enabled_channels] = subscribes.pluck(:id) unless for_you_settings.key?(:enabled_channels)

    # For You Feed Settings
    for_you_settings[:curated_by_mammoth] = 1 unless for_you_settings.key?(:curated_by_mammoth)
    for_you_settings[:friends_of_friends] = 1 unless for_you_settings.key?(:friends_of_friends)
    for_you_settings[:from_your_channels] = 1 unless for_you_settings.key?(:from_your_channels)
    for_you_settings[:your_follows] = 1 unless for_you_settings.key?(:your_follows)
  end
end

# {"curated_by_mammoth":3,"friends_of_friends":2,"from_your_channels":3,"type":"personal","status":"idle","your_follows":1,"enabled_channels":["3da58e91-b15d-45ae-abdb-e55a0bd37628","cde1dcdc-d295-46b3-a155-1664862faca1"]}
