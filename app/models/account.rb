class Account < ApplicationRecord
  validates :handle, uniqueness: { scope: :instance_id }
  belongs_to :instance
end
