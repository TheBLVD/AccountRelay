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
  validates :username, uniqueness: { scope: :domain }

  has_many :active_relationships,  class_name: 'Follow', foreign_key: 'user_id',        dependent: :destroy
  has_many :passive_relationships, class_name: 'Follow', foreign_key: 'target_user_id', dependent: :destroy

  has_many :following, -> { order('follows.id desc') }, through: :active_relationships,  source: :target_user
  has_many :followers, -> { order('follows.id desc') }, through: :passive_relationships, source: :user

  def follow!(other_user)
    rel = active_relationships.find_or_create_by!(target_user: other_user)
    Rails.logger.debug "SAVE_FOLLOW:: HAS_CHANGED:: #{rel.changed?}"
    rel.save! if rel.changed?

    rel
  end
end
