class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items, dependent: :destroy
  has_many :merchants, through: :items
  has_many :transactions, dependent: :destroy
  has_many :bulk_discounts, through: :merchants

  validates_presence_of :status

  def total_revenue
    invoice_items.sum('unit_price * quantity') * 0.01.to_f
  end

  def incomplete?
    invoice_items.where.not(status: 'shipped').count > 0
  end

  def self.oldest_first
    order(:created_at)
  end

  def merchant_revenue(merchant)
    items.where(merchant_id: merchant.id)
    .sum('invoice_items.unit_price * invoice_items.quantity') * 0.01.to_f
  end

  def total_discounted_revenue
    invoice_items.map { |invoice_item| invoice_item.total_price }.sum
  end
end
