class Order < ApplicationRecord
  ALLOWED_GIFTS= %w[MUG T_SHIRT HOODIE STICKER].freeze
  ALLOWED_STATUS= %w[ORDER_RECEIVED ORDER_PROCESSING ORDER_SHIPPED ORDER_CANCELLED].freeze

  has_many :recipients, autosave: true
  validates :gift_type, inclusion: { in: ALLOWED_GIFTS }
  validates :status, inclusion: { in: ALLOWED_STATUS }
  validates :recipient_ids, :length => { :minimum => 1 }
  validate :status_check, on: :update

  def status_check
    errors.add(:status, "Status in ORDER_SHIPPED") if Order.find(self.id).status == "ORDER_SHIPPED"
  end
end
