class BulkDiscount < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :percentage
  validates_presence_of :quantity_threshold

  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoices, through: :merchant
  has_many :invoice_items, through: :invoices
end
