class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices
  has_many :bulk_discounts

  validates_presence_of :name

  def items_to_ship
    items.joins(:invoice_items).select("items.name, invoice_items.invoice_id").where.not("invoice_items.status = 'shipped'")
  end

  def enabled_items
    items.where("items.status = 0")
  end

  def disabled_items
      items.where("items.status = 1")
  end

  def indiv_invoice_ids
    InvoiceItem.all.where(item_id: items.ids).pluck(:invoice_id).uniq
  end

  def my_total_revenue(invoice)
    invoice_items.where(invoice_items: {invoice_id: invoice.id} ).sum('invoice_items.unit_price * quantity')* 0.01.to_f
  end

  def top_5_items
    items.joins(invoices: :transactions)
    .where(transactions: {result: 'success'})
    .select("items.*, sum(invoice_items.quantity * invoice_items.unit_price) AS total_revenue")
    .group(:id)
    .order("total_revenue DESC")
    .limit(5)
  end

  def self.top_five_revenue
    joins(invoice_items: :transactions)
        .where(transactions: {result: 'success'})
        .select("merchants.*, sum(invoice_items.unit_price * invoice_items.quantity) as total")
        .group(:id)
        .order(total: :desc)
        .limit(5)
  end


   def best_date
    invoices.joins(:invoice_items)
    .where("invoices.status = 'Completed'")
    .select('invoices.*, sum(invoice_items.unit_price * invoice_items.quantity) AS revenue')
    .group(:id)
    .order("revenue desc")
    .first.created_at_format
  end

  def fave_customers
    customers.joins(invoices: :invoice_items)
          .joins(invoices: :transactions)
          .where(transactions: {result: 'success'})
          .select("customers.*, count(result)as count")
          .group(:id).order(count: :desc)
          .limit(5)
  end
end
