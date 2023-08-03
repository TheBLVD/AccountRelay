# frozen_string_literal: true

# == Schema Information
#
# Table name: follows
#
#  id                :bigint(8)        not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id        :bigint(8)        not null
#  target_user_id :bigint(8)        not null

class Follow < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :target_user, class_name: 'User'

  validates :user_id, uniqueness: { scope: :target_user_id }

  scope :recent, -> { reorder(id: :desc) }
end
