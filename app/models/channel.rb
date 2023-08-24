# frozen_string_literal: true

# == Schema Information
#
# Table name: channels
#
#  id                            :uuid        not null, primary key
#  description                   :text        what is the channel about
#  hidden                        :boolean     default to TRUE, must be manually enabled
#  owner                         :reference   a user must own a channel, usually the user who made it.
#

class Channel < ApplicationRecord
  belongs_to :owner, class_name: 'User'
end
