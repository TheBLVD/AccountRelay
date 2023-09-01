# frozen_string_literal: true

# == Schema Information
#
# Table name: subscribes
#
#  id                :uuid             not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :uuid             not null
#  channel_id        :uuid             not null

class Subscribe < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  validates :user_id, uniqueness: { scope: :channel_id }
end
