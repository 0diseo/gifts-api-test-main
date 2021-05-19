class Recipient < ApplicationRecord
  belongs_to :user
  belongs_to :school
  belongs_to :order, optional: true
  validates :address, presence: true
end
