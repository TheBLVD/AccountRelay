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

class User < ApplicationRecord
  serialize :for_you_settings, JsonbSerializers
  store_accessor :curated_by_mammoth, :friends_of_friends, :from_your_channels, :your_follows, :status

  FOR_YOU_SETTINGS_SCHEMA = Rails.root.join('app', 'models', 'schemas', 'user_for_you_settings.json')
  validates :for_you_settings, presence: true, json: { message: ->(errors) { errors }, schema: FOR_YOU_SETTINGS_SCHEMA }
  validates :username, uniqueness: { scope: :domain }

  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'user_id',        dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_user_id', dependent: :destroy

  has_many :passive_channels, class_name: 'ChannelAccount', foreign_key: 'user_id', dependent: :destroy

  has_many :following, -> { order('follows.id desc') }, through: :active_relationships,  source: :target_user
  has_many :followers, -> { order('follows.id desc') }, through: :passive_relationships, source: :user

  after_initialize :set_defaults
  before_validation :set_defaults

  def follow!(other_user)
    rel = active_relationships.find_or_create_by!(target_user: other_user)
    Rails.logger.debug "SAVE_FOLLOW:: HAS_CHANGED:: #{rel.changed?}"
    rel.save! if rel.changed?

    rel
  end

  def acct
    "#{username}@#{domain}"
  end

  # Settings will be off, low, med, high
  # So the enum 0-3 to match
  # hash[:key] = 0 unless hash.has_key?(:key)
  def set_defaults
    Rails.logger.debug 'SETTING DEFAULTS'
    for_you_settings[:type] = local? ? 'personal' : 'public'
    return unless local? # early return if user is not a Mammoth user

    # For You Status Of
    for_you_settings[:status] = 'idle' unless for_you_settings.key?(:status)

    # For You Feed Settings
    for_you_settings[:curated_by_mammoth] = 3 unless for_you_settings.key?(:curated_by_mammoth)
    for_you_settings[:friends_of_friends] = 3 unless for_you_settings.key?(:friends_of_friends)
    for_you_settings[:from_your_channels] = 3 unless for_you_settings.key?(:from_your_channels)
    for_you_settings[:your_follows] = 3 unless for_you_settings.key?(:your_follows)
  end
end
