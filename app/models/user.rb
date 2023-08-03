# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
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

class User < ApplicationRecord
  validates :username, uniqueness: { scope: :domain }
end
