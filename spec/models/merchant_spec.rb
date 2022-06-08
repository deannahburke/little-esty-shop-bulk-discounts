require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it {should have_many :items}
    it {should have_many(:invoice_items).through(:items)}
  end

  describe 'validations' do
    it {should validate_presence_of(:name)}
  end

  describe 'instance methods' do
    before(:each) do
      @billman = Merchant.create!(name: "Billman")
      @jacobs = Merchant.create!(name: "Jacobs")
      @burke = Merchant.create!(name: "Burke")
      @hall = Merchant.create!(name: "Hall")
      @chris = Merchant.create!(name: "Chris")
      @mikedao = Merchant.create!(name: "Mike Dao")

      @brenda = Customer.create!(first_name: "Brenda", last_name: "Bhoddavista")

      @bracelet = @billman.items.create!(name: "Bracelet", description: "shiny", unit_price: 1001)
      @mood = @billman.items.create!(name: "Mood Ring", description: "Moody", unit_price: 2002)
      @stuff1 = @jacobs.items.create!(name: "macbook", description: "Moody", unit_price: 3002)
      @stuff2 = @burke.items.create!(name: "stuff2", description: "Moody", unit_price: 4002)
      @stuff3 = @hall.items.create!(name: "stuff4", description: "Moody", unit_price: 5002)
      @stuff4 = @chris.items.create!(name: "stuff6", description: "Moody", unit_price: 6002)
      @stuff5 = @mikedao.items.create!(name: "stuff8", description: "Moody", unit_price: 7002)

      @invoice1 = @brenda.invoices.create!(status: "In Progress")
      @invoice2 = @brenda.invoices.create!(status: "Completed")
      @invoice3 = @brenda.invoices.create!(status: "Completed")
      @invoice4 = @brenda.invoices.create!(status: "Completed")

      @transaction1 = @invoice1.transactions.create!(credit_card_number: 4654405418249632, result: "success", created_at: Time.now, updated_at: Time.now)
      @transaction2 = @invoice2.transactions.create!(credit_card_number: 4654405418249632, result: "success", created_at: Time.now, updated_at: Time.now)
      @transaction3 = @invoice3.transactions.create!(credit_card_number: 4654405418249632, result: "success", created_at: Time.now, updated_at: Time.now)
      @transaction4 = @invoice4.transactions.create!(credit_card_number: 4654405418249632, result: "success", created_at: Time.now, updated_at: Time.now)

      @order1 = @bracelet.invoice_items.create!(quantity: 1, unit_price: 1001, status: "Pending", invoice_id: @invoice1.id)
      @order2 = @mood.invoice_items.create!(quantity: 1, unit_price: 2002, status: "Packaged", invoice_id: @invoice1.id)
      @order3 = @mood.invoice_items.create!(quantity: 3, unit_price: 2002, status: "Shipped", invoice_id: @invoice2.id)
      InvoiceItem.create!(item_id: @stuff1.id, invoice_id: @invoice2.id, quantity: 1, unit_price: 1000, status: "Shipped")
      InvoiceItem.create!(item_id: @stuff2.id, invoice_id: @invoice3.id, quantity: 2, unit_price: 1000, status: "Shipped")
      InvoiceItem.create!(item_id: @stuff3.id, invoice_id: @invoice4.id, quantity: 3, unit_price: 1000, status: "Shipped")
      InvoiceItem.create!(item_id: @stuff4.id, invoice_id: @invoice3.id, quantity: 4, unit_price: 1000, status: "Shipped")
      InvoiceItem.create!(item_id: @stuff5.id, invoice_id: @invoice4.id, quantity: 5, unit_price: 1000, status: "Shipped")
    end

    it 'items_to_ship returns an array of items that are not shipped' do
      expect(@billman.items_to_ship[0].name).to eq("Bracelet")
      expect(@billman.items_to_ship[1].name).to eq("Mood Ring")
      expect(@billman.items_to_ship[0].invoice_id).to eq(@invoice1.id)
      expect(@billman.items_to_ship[1].invoice_id).to eq(@invoice1.id)
      expect(@billman.items_to_ship.pluck(:name)).to eq(["Bracelet", "Mood Ring"])
      expect(@billman.items_to_ship.pluck(:invoice_id)).to eq([@invoice1.id, @invoice1.id])
      expect(@billman.items_to_ship.pluck(:invoice_id)).to_not eq([@invoice2.id])
    end


    it 'indiv_invoice_ids returns an array of invoice ids for a merchant' do
      parker = Merchant.create!(name: "Parker's Perfection Pagoda")
      jimbob = Customer.create!(first_name: "Jimbob", last_name: "Dudeguy")
      invoice3 = jimbob.invoices.create!(status: "Completed")
      invoice4 = jimbob.invoices.create!(status: "Completed")
      expect(@billman.indiv_invoice_ids).to eq([@invoice1.id, @invoice2.id])
      expect(@billman.indiv_invoice_ids).to_not eq([invoice3.id, invoice4.id])
    end

    it 'my_total_revenue can return a single merchants revenue for an invoice' do
      parker = Merchant.create!(name: "Parker's Perfection Pagoda")
      jimbob = Customer.create!(first_name: "Jimbob", last_name: "Dudeguy")
      invoice3 = jimbob.invoices.create!(status: "Completed")
      invoice4 = jimbob.invoices.create!(status: "Completed")
      beard = parker.items.create!(name: "Beard Oil", description: "Lavender Scented", unit_price: 5099)

      order6 = @bracelet.invoice_items.create!(quantity: 2, unit_price: 1001, status: "Pending", invoice_id: invoice3.id)
      order7 = beard.invoice_items.create!(quantity: 3, unit_price: 5099, status: "Packaged", invoice_id: invoice3.id)

      expect(@billman.my_total_revenue(invoice3)).to eq(20.02)
      expect(@billman.my_total_revenue(invoice3)).to_not eq(172.99)
    end

    it "gives top 5 merchants by total total_revenue" do
      expect(Merchant.top_five_revenue).to eq([@billman,@mikedao,@chris,@hall,@burke])
    end

    it '#top_sales_day returns merchants date of highest sale' do
      @merchantA = Merchant.create!(name: "Billman")
      @merchantB = Merchant.create!(name: "Burke")
      @merchantD= Merchant.create!(name: "Hall")
      @merchantC = Merchant.create!(name: "Chris")
      @merchantE= Merchant.create!(name: "Mike Dao")

      @itemA = @merchantA.items.create!(name: 'itemA', description: 'Description1', unit_price: 222, status: 0)
      @itemB = @merchantB.items.create!(name: 'itemB', description: 'Descriptions', unit_price: 222,status: 0)
      @itemD = @merchantD.items.create!(name: 'itemD', description: 'Descriptive', unit_price: 222, status: 0)
      @itemC = @merchantC.items.create!(name: 'itemC', description: 'Descriptionless', unit_price: 222, status: 0)
      @itemE = @merchantE.items.create!(name: 'ItemE', description: 'Descriptionulous', unit_price: 222, status: 0)

      @customer1 = Customer.create!(first_name: "Cuss", last_name: "Tomer")

      @invoiceA1 = @customer1.invoices.create!(status: "Completed", created_at: "01-01-01")
      @invoiceA2 = @customer1.invoices.create!(status: "Completed", created_at: "01-02-01")
      @invoiceA3 = @customer1.invoices.create!(status: "Completed", created_at: "01-02-01")
      @invoiceB1 = @customer1.invoices.create!(status: "Completed", created_at: "02-01-02")
      @invoiceB2 = @customer1.invoices.create!(status: "Completed", created_at: "02-02-02")      
      @invoiceB3 = @customer1.invoices.create!(status: "Completed", created_at: "02-02-02")     
      @invoiceD1 = @customer1.invoices.create!(status: "Completed", created_at: "03-01-03")
      @invoiceD2 = @customer1.invoices.create!(status: "Completed", created_at: "03-02-03")
      @invoiceD3 = @customer1.invoices.create!(status: "Completed", created_at: "03-02-03")
      @invoiceC1 = @customer1.invoices.create!(status: "Completed", created_at: "04-01-04")
      @invoiceC2 = @customer1.invoices.create!(status: "Completed", created_at: "04-02-04")
      @invoiceC3 = @customer1.invoices.create!(status: "Completed", created_at: "04-02-04")
      @invoiceE1 = @customer1.invoices.create!(status: "Completed", created_at: "05-01-05")
      @invoiceE2 = @customer1.invoices.create!(status: "Completed", created_at: "05-02-05")
      @invoiceE3 = @customer1.invoices.create!(status: "Completed", created_at: "05-02-05")

      @transactionA1 = @invoiceA1.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionB1 = @invoiceB1.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionD1 = @invoiceD1.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionC1 = @invoiceC1.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionE1 = @invoiceE1.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionA2 = @invoiceA2.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionB2 = @invoiceB2.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionD2 = @invoiceD2.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionC2 = @invoiceC2.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionE2 = @invoiceE2.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionA3 = @invoiceA3.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionB3 = @invoiceB3.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionD3 = @invoiceD3.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionC3 = @invoiceC3.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transactionE3 = @invoiceE3.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )

      @invoice_itemA1 = @invoiceA1.invoice_items.create!(quantity: 1, unit_price: 10, item_id: @itemA.id, status: "shipped")
      @invoice_itemA2 = @invoiceA2.invoice_items.create!(quantity: 2, unit_price: 10, item_id: @itemA.id, status: "shipped")
      @invoice_itemA3 = @invoiceA3.invoice_items.create!(quantity: 3, unit_price: 10, item_id: @itemA.id, status: "shipped")
      @invoice_itemB1 = @invoiceB1.invoice_items.create!(quantity: 1, unit_price: 8, item_id: @itemB.id, status: "shipped")
      @invoice_itemB2 = @invoiceB2.invoice_items.create!(quantity: 2, unit_price: 8, item_id: @itemB.id, status: "shipped")
      @invoice_itemB3 = @invoiceB3.invoice_items.create!(quantity: 3, unit_price: 8, item_id: @itemB.id, status: "shipped")
      @invoice_itemD1 = @invoiceD1.invoice_items.create!(quantity: 1, unit_price: 6, item_id: @itemD.id, status: "shipped")
      @invoice_itemD2 = @invoiceD2.invoice_items.create!(quantity: 2, unit_price: 6, item_id: @itemD.id, status: "shipped")
      @invoice_itemD3 = @invoiceD3.invoice_items.create!(quantity: 3, unit_price: 6, item_id: @itemD.id, status: "shipped")
      @invoice_itemC1 = @invoiceC1.invoice_items.create!(quantity: 1, unit_price: 4, item_id: @itemC.id, status: "shipped")
      @invoice_itemC2 = @invoiceC2.invoice_items.create!(quantity: 2, unit_price: 4, item_id: @itemC.id, status: "shipped")
      @invoice_itemC3 = @invoiceC3.invoice_items.create!(quantity: 3, unit_price: 4, item_id: @itemC.id, status: "shipped")
      @invoice_itemE1 = @invoiceE1.invoice_items.create!(quantity: 1, unit_price: 2, item_id: @itemE.id, status: "shipped")
      @invoice_itemE2 = @invoiceE2.invoice_items.create!(quantity: 2, unit_price: 2, item_id: @itemE.id, status: "shipped")
      @invoice_itemE3 = @invoiceE3.invoice_items.create!(quantity: 3, unit_price: 2, item_id: @itemE.id, status: "shipped")

      expect(@merchantA.best_date).to have_content("01-02-01")
      expect(@merchantB.best_date).to have_content("02-02-02")
      expect(@merchantD.best_date).to have_content("03-02-03")
      expect(@merchantC.best_date).to have_content("04-02-04")
      expect(@merchantE.best_date).to have_content("05-02-05")
    end
  end
end
