class ChannelAccount < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :channel, class_name: 'Channel'

  validates :user_id, uniqueness: { scope: :channel_id }

  scope :recent, -> { reorder(id: :desc) }
end
