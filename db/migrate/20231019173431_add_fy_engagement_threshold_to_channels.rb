class AddFyEngagementThresholdToChannels < ActiveRecord::Migration[6.1]
  def change
    add_column :channels, :fy_engagement_threshold, :int, default: 0
  end
end
