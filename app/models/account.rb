class Account < ApplicationRecord
  validates :handle, uniqueness: { scope: :owner }
  belongs_to :instance
end
