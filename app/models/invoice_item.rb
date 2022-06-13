class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_many :transactions, through: :invoice
  has_many :merchants, through: :item
  has_many :bulk_discounts, through: :merchants

  validates_presence_of :quantity
  validates_presence_of :unit_price
  validates_presence_of :status

  def price_convert
    unit_price * 0.01.to_f
  end

  def belongs_to_merchant(merchant)
    item.merchant == merchant
  end

  def greatest_percent_discount
    bulk_discounts.where('quantity_threshold <= ?', quantity)
    .order(percentage: :desc)
    .first
  end

  def regular_price
    (price_convert * quantity)
  end

  def discount_price
    discount = regular_price * greatest_percent_discount.percentage
    regular_price - (discount / 100).round(2)
  end

  def total_price
    if greatest_percent_discount.present?
      discount_price
    else
      regular_price
    end
  end
end
