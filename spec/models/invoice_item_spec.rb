require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  before :each do
    @billman = Merchant.create!(name: "Billman")
    @parker = Merchant.create!(name: "Parker's Perfection Pagoda")

    @bracelet = @billman.items.create!(name: "Bracelet", description: "shiny", unit_price: 1001)
    @mood = @billman.items.create!(name: "Mood Ring", description: "moody", unit_price: 500)
    @necklace = @billman.items.create!(name: "Necklace", description: "sparkly", unit_price: 2000)

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: "Ondricka")

    @invoice_1 = @customer_1.invoices.create!(status: "in progress")
    @invoice_2 = @customer_1.invoices.create!(status: "in progress")
    @invoice_3 = @customer_1.invoices.create!(status: "completed")

    @invoice_items_1 = @bracelet.invoice_items.create!(quantity: 1, unit_price: 1001, status: "Pending", invoice_id: @invoice_1.id)
    @invoice_items_2 = @mood.invoice_items.create!(quantity: 2, unit_price: 500, status: "Pending", invoice_id: @invoice_1.id)
    @invoice_items_3 = @bracelet.invoice_items.create!(quantity: 4, unit_price: 1001, status: "Pending", invoice_id: @invoice_1.id)
    @invoice_items_4 = @necklace.invoice_items.create!(quantity: 1, unit_price: 2000, status: "Pending", invoice_id: @invoice_2.id)


    @discount1 = @billman.bulk_discounts.create!(name: "Bulk2", percentage: 15, quantity_threshold: 2)
    @discount2 = @billman.bulk_discounts.create!(name: "Bulk5", percentage: 20, quantity_threshold: 5)
  end

  describe 'relationships' do
    it {should belong_to :item}
    it {should belong_to :invoice}
    it {should have_many(:merchants).through(:item)}
    it {should have_many(:bulk_discounts).through(:merchants)}
  end

  describe 'validations' do
    it {should validate_presence_of(:quantity)}
    it {should validate_presence_of(:unit_price)}
    it {should validate_presence_of(:status)}

  end

  describe "instance methods" do
    it "converts unit price into dollar format" do
      expect(@invoice_items_1.price_convert).to eq(10.01)
    end

    it 'belongs to merchant returns true if an invoice item belongs to the given merchant' do

      expect(@invoice_items_1.belongs_to_merchant(@billman)).to eq(true)
    end

    it 'belongs to merchant returns false if an invoice item does not belong to the given merchant' do

      expect(@invoice_items_1.belongs_to_merchant(@parker)).to eq(false)
    end

    it 'determines bulk discount for quantity threshold with greatest percentage' do
      expect(@invoice_items_1.greatest_percent_discount).to eq(nil)
      expect(@invoice_items_1.greatest_percent_discount).to_not eq(@discount1)
      expect(@invoice_items_1.greatest_percent_discount).to_not eq(@discount2)

      expect(@invoice_items_2.greatest_percent_discount).to eq(@discount1)
      expect(@invoice_items_2.greatest_percent_discount).to_not eq(@discount2)

      expect(@invoice_items_3.greatest_percent_discount).to eq(@discount1)
      expect(@invoice_items_3.greatest_percent_discount).to_not eq(@discount2)
    end

    it 'determines regular price for an invoice item' do
      expect(@invoice_items_1.regular_price).to eq(10.01)
      expect(@invoice_items_2.regular_price).to eq(10.00)
      expect(@invoice_items_3.regular_price).to eq(40.04)
      expect(@invoice_items_4.regular_price).to eq(20.00)
    end

    it 'determines discounted price for an invoice item' do
      expect(@invoice_items_2.discount_price).to eq(8.50)
      expect(@invoice_items_3.discount_price).to eq(34.03)
    end

    it 'determines total price of invoice items' do
      expect(@invoice_items_1.total_price).to eq(10.01)
      expect(@invoice_items_2.total_price).to eq(8.50)
      expect(@invoice_items_3.total_price).to eq(34.03)
      expect(@invoice_items_4.total_price).to eq(20.00)
    end
  end
end
