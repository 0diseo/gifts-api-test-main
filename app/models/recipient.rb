class Recipient < ApplicationRecord
  belongs_to :user
  belongs_to :school, optional: true
  belongs_to :order, optional: true
  validates :address, presence: true
end
