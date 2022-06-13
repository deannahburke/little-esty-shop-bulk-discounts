require 'rails_helper'

RSpec.describe Invoice, type: :model do
  before :each do
    @billman = Merchant.create!(name: "Billman")

    @bracelet = @billman.items.create!(name: "Bracelet", description: "shiny", unit_price: 1001)
    @mood = @billman.items.create!(name: "Mood Ring", description: "Moody", unit_price: 2002)

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: "Ondricka")

    @invoice_1 = @customer_1.invoices.create!(status: "cancelled", created_at: Time.now - 1.days)
    @invoice_2 = @customer_1.invoices.create!(status: "cancelled", created_at: Time.now - 2.days)
    @invoice_3 = @customer_1.invoices.create!(status: "cancelled", created_at: Time.now - 3.days)
    @invoice_4 = @customer_1.invoices.create!(status: "in progress", created_at: Time.now - 4.days)

    @invoice_items_1 = @bracelet.invoice_items.create!(quantity: 1, unit_price: 1001, status: "pending", invoice_id: @invoice_1.id)
    @invoice_items_2 = @mood.invoice_items.create!(quantity: 1, unit_price: 2002, status: "pending", invoice_id: @invoice_1.id)
    @invoice_items_3 = @bracelet.invoice_items.create!(quantity: 1, unit_price: 1001, status: "shipped", invoice_id: @invoice_2.id)
    @invoice_items_4 = @mood.invoice_items.create!(quantity: 1, unit_price: 2002, status: "packaged", invoice_id: @invoice_3.id)
    @invoice_items_5 = @bracelet.invoice_items.create!(quantity: 1, unit_price: 1001, status: "shipped", invoice_id: @invoice_3.id)

    @invoice_items_6 = @bracelet.invoice_items.create!(quantity: 1, unit_price: 1001, status: "shipped", invoice_id: @invoice_4.id)
    @invoice_items_7 = @mood.invoice_items.create!(quantity: 2, unit_price: 2002, status: "shipped", invoice_id: @invoice_4.id)

    @discount1 = @billman.bulk_discounts.create!(name: "Bulk2", percentage: 15, quantity_threshold: 2)
    @discount2 = @billman.bulk_discounts.create!(name: "Bulk5", percentage: 20, quantity_threshold: 5)
  end

  describe 'relationships' do
    it {should belong_to :customer}
    it {should have_many :transactions}
    it {should have_many :invoice_items}
    it {should have_many(:items).through(:invoice_items)}
    it {should have_many(:merchants).through(:items)}
    it {should have_many(:bulk_discounts).through(:merchants)}
  end

  describe 'validations' do
    it {should validate_presence_of(:status)}
  end

  describe 'instance methods' do
    it "can give total revenue for invoice" do
      expect(@invoice_1.total_revenue).to eq(30.03)
    end

    it "determines incomplete invoices" do
      expect(@invoice_1.incomplete?).to eq(true)
      expect(@invoice_2.incomplete?).to eq(false)
      expect(@invoice_3.incomplete?).to eq(true)
    end

    it "can order invoices by date desc" do
      expect(Invoice.oldest_first).to eq([@invoice_4, @invoice_3,@invoice_2, @invoice_1])
    end

    it 'can determine total discounted revenue for an invoice' do
      expect(@invoice_4.total_discounted_revenue).to eq(44.04)
      expect(@invoice_4.total_discounted_revenue).to_not eq(50.05)
    end

    it 'returns single merchants pre-discount revenue for an invoice' do
      brenda = Customer.create!(first_name: "Brenda", last_name: "Bhoddavista")
      invoice5 = brenda.invoices.create!(status: "Completed")
      order8 = @bracelet.invoice_items.create!(quantity: 2, unit_price: 1001, status: "Pending", invoice_id: invoice5.id)
      order9 = @mood.invoice_items.create!(quantity: 1, unit_price: 2002, status: "Pending", invoice_id: invoice5.id)

      parker = Merchant.create!(name: "Parker's Perfection Pagoda")
      jimbob = Customer.create!(first_name: "Jimbob", last_name: "Dudeguy")
      invoice6 = jimbob.invoices.create!(status: "Completed")

      beard = parker.items.create!(name: "Beard Oil", description: "Lavender Scented", unit_price: 5099)
      balm = parker.items.create!(name: "Balm", description: "Balmy", unit_price: 1000)
      order10 = beard.invoice_items.create!(quantity: 1, unit_price: 5099, status: "Pending", invoice_id: invoice6.id)
      order11 = balm.invoice_items.create!(quantity: 2, unit_price: 1000, status: "Pending", invoice_id: invoice6.id)
      order12 = @mood.invoice_items.create!(quantity: 2, unit_price: 1001, status: "Pending", invoice_id: invoice6.id)

      expect(invoice5.merchant_revenue(@billman)).to eq(40.04)
      expect(invoice5.merchant_revenue(parker)).to eq(0)
      expect(invoice6.merchant_revenue(@billman)).to eq(20.02)
      expect(invoice6.merchant_revenue(parker)).to eq(70.99)
    end

    it 'only applies the merchants discounts to their items on an invoice' do
      brenda = Customer.create!(first_name: "Brenda", last_name: "Bhoddavista")
      invoice5 = brenda.invoices.create!(status: "Completed")
      order8 = @bracelet.invoice_items.create!(quantity: 2, unit_price: 1001, status: "Pending", invoice_id: invoice5.id)
      order9 = @mood.invoice_items.create!(quantity: 1, unit_price: 2002, status: "Pending", invoice_id: invoice5.id)
      discount1 = @billman.bulk_discounts.create!(name: "Bulk2", percentage: 15, quantity_threshold: 2)
      discount2 = @billman.bulk_discounts.create!(name: "Bulk5", percentage: 20, quantity_threshold: 5)

      parker = Merchant.create!(name: "Parker's Perfection Pagoda")
      jimbob = Customer.create!(first_name: "Jimbob", last_name: "Dudeguy")
      invoice6 = jimbob.invoices.create!(status: "Completed")

      beard = parker.items.create!(name: "Beard Oil", description: "Lavender Scented", unit_price: 5099)
      balm = parker.items.create!(name: "Balm", description: "Balmy", unit_price: 1000)
      order10 = beard.invoice_items.create!(quantity: 1, unit_price: 5099, status: "Pending", invoice_id: invoice6.id)
      order11 = balm.invoice_items.create!(quantity: 2, unit_price: 1000, status: "Pending", invoice_id: invoice6.id)
      order12 = @mood.invoice_items.create!(quantity: 2, unit_price: 1001, status: "Pending", invoice_id: invoice6.id)
      discount3 = parker.bulk_discounts.create!(name: "Bulk2", percentage: 10, quantity_threshold: 2)
      discount4 = parker.bulk_discounts.create!(name: "Bulk10", percentage: 20, quantity_threshold: 10)

      expect(invoice6.total_discounted_revenue).to eq(86.01)
      expect(invoice6.total_discounted_revenue).to_not eq(91.01)
    end

    xit 'returns a specific merchants discounted revenue' do
      brenda = Customer.create!(first_name: "Brenda", last_name: "Bhoddavista")
      invoice5 = brenda.invoices.create!(status: "Completed")
      order8 = @bracelet.invoice_items.create!(quantity: 2, unit_price: 1001, status: "Pending", invoice_id: invoice5.id)
      order9 = @mood.invoice_items.create!(quantity: 1, unit_price: 2002, status: "Pending", invoice_id: invoice5.id)
      discount1 = @billman.bulk_discounts.create!(name: "Bulk2", percentage: 15, quantity_threshold: 2)
      discount2 = @billman.bulk_discounts.create!(name: "Bulk5", percentage: 20, quantity_threshold: 5)

      parker = Merchant.create!(name: "Parker's Perfection Pagoda")
      jimbob = Customer.create!(first_name: "Jimbob", last_name: "Dudeguy")
      invoice6 = jimbob.invoices.create!(status: "Completed")

      beard = parker.items.create!(name: "Beard Oil", description: "Lavender Scented", unit_price: 5099)
      balm = parker.items.create!(name: "Balm", description: "Balmy", unit_price: 1000)
      order10 = beard.invoice_items.create!(quantity: 1, unit_price: 5099, status: "Pending", invoice_id: invoice6.id)
      order11 = balm.invoice_items.create!(quantity: 2, unit_price: 1000, status: "Pending", invoice_id: invoice6.id)
      order12 = @mood.invoice_items.create!(quantity: 2, unit_price: 2002, status: "Pending", invoice_id: invoice6.id)
      discount3 = parker.bulk_discounts.create!(name: "Bulk2", percentage: 10, quantity_threshold: 2)
      discount4 = parker.bulk_discounts.create!(name: "Bulk10", percentage: 20, quantity_threshold: 10)

      expect(invoice5.merchant_discount_revenue(@billman)).to eq(37.04)
      expect(invoice5.merchant_discount_revenue(parker)).to eq(nil)
      expect(invoice5.merchant_discount_revenue(@billman)).to_nto eq(40.04)

      expect(invoice6.merchant_discount_revenue(@billman)).to eq(34.04)
      expect(invoice6.merchant_discount_revenue(parker)).to eq(68.99)
      expect(invoice6.merchant_discount_revenue(@billman)).to_not eq(40.04)
      expect(invoice6.merchant_discount_revenue(parker)).to_not eq(70.99)
    end
  end
end
