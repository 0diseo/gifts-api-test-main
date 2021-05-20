class Order < ApplicationRecord

  ALLOWED_STATUS= %w[ORDER_RECEIVED ORDER_PROCESSING ORDER_SHIPPED ORDER_CANCELLED].freeze

  has_many :recipients, autosave: true
  validates :status, inclusion: { in: ALLOWED_STATUS }
  validates :recipient_ids, :length => { :minimum => 1 }
  validates :recipient_ids, :length => { :maximum => 20 }
  validate :status_check, on: :update

  def status_check
    errors.add(:status, "Status in ORDER_SHIPPED") if Order.find(self.id).status == "ORDER_SHIPPED"
  end
end
