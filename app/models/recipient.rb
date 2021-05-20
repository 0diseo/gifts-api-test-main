class Recipient < ApplicationRecord
  ALLOWED_GIFTS= %w[MUG T_SHIRT HOODIE STICKER].freeze

  belongs_to :user
  belongs_to :school, optional: true
  belongs_to :order, optional: true
  validates :address, presence: true
  validates :gift, inclusion: { in: ALLOWED_GIFTS }
  validates :gift, :length => { :maximum => 3 }

end
