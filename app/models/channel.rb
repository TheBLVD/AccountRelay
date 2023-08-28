# frozen_string_literal: true

# == Schema Information
#
# Table name: channels
#
#  id                            :uuid        not null, primary key
#  title                         :string      display header for channel name
#  description                   :text        what is the channel about
#  hidden                        :boolean     default to TRUE, must be manually enabled
#  owner                         :reference   a user must own a channel, usually the user who made it.
#

class Channel < ApplicationRecord
  belongs_to :owner, class_name: 'User'

  has_many :passive_relationships, class_name: 'ChannelAccount', dependent: :destroy, foreign_key: 'channel_id'

  has_many :accounts, lambda {
                        order('channel_accounts.id desc')
                      }, through: :passive_relationships, source: :user

  def add_account!(user)
    rel = passive_relationships.find_or_create_by!(user:)
    Rails.logger.debug "SAVE_ACCOUNT_TO_CHANNEL:: HAS_CHANGED:: #{rel.changed?}"
    rel.save! if rel.changed?

    rel
  end

  def remove_account!(user)
    rel = passive_relationships.find_by(user:)
    rel&.destroy
  end
end
