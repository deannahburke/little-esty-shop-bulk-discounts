require "rails_helper"

RSpec.describe 'Admin Merchant Index Page' do
  before :each do
    @billman = Merchant.create!(name: "Billman")
    @jacobs = Merchant.create!(name: "Jacobs")
  end

  it "shows the name of each merchant" do
    visit admin_merchants_path
    expect(page).to have_content(@jacobs.name)
    expect(page).to have_content(@billman.name)
  end

  it "has a link to show page for each merchant name" do
    visit admin_merchants_path
    click_link ("#{@jacobs.name}")
    expect(current_path).to eq(admin_merchant_path(@jacobs.id))
  end

  it "can update merchant status to enabled/disabled" do
    visit admin_merchants_path
    expect(page).to_not have_button("Enable")
    expect(page).to have_button("Disable", count: 2)
    click_button 'Disable', match: :first

    expect(current_path).to eq(admin_merchants_path)
    expect(page).to have_button("Disable", count: 1)
    expect(page).to have_button("Enable", count: 1)
  end

  it "links to a new page for creating a new merchant " do
    visit admin_merchants_path
    click_link "Create New Merchant"
    expect(current_path).to eq(new_admin_merchant_path)
  end

  it "shows top 5 merchants by total revenue" do
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

    visit admin_merchants_path
    within '#top5' do

      expect(@billman.name).to appear_before(@mikedao.name)
      expect(@mikedao.name).to appear_before(@chris.name)
      expect(@chris.name).to appear_before(@hall.name)
      expect(@hall.name).to appear_before(@burke.name)

      expect(page).to_not have_content(@jacobs.name)
    end
  end

  it "shows top 5 merchants highest sales date" do
    @merchantA = Merchant.create!(name: "merchantA")
    @merchantB = Merchant.create!(name: "merchantB")
    @merchantD= Merchant.create!(name: "merchantD")
    @merchantC = Merchant.create!(name: "merchantC")
    @merchantE= Merchant.create!(name: "merchantE")

    @itemA = @merchantA.items.create!(name: 'itemA', description: 'Description1', unit_price: 222, status: 0)
    @itemB = @merchantB.items.create!(name: 'itemB', description: 'Descriptions', unit_price: 222,status: 0)
    @itemD = @merchantD.items.create!(name: 'itemD', description: 'Descriptive', unit_price: 222, status: 0)
    @itemC = @merchantC.items.create!(name: 'itemC', description: 'Descriptionless', unit_price: 222, status: 0)
    @itemE = @merchantE.items.create!(name: 'ItemE', description: 'Descriptionulous', unit_price: 222, status: 0)

    @customer1 = Customer.create!(first_name: "Cuss", last_name: "Tomer")

    @invoiceA1 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-27 14:53:59")
    @invoiceA2 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-28 14:53:59")
    @invoiceA3 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-28 14:53:59")
    @invoiceB1 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-29 14:53:59")
    @invoiceB2 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-30 14:53:59")
    @invoiceB3 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-30 14:53:59")
    @invoiceD1 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-01 14:53:59")
    @invoiceD2 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-02 14:53:59")
    @invoiceD3 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-02 14:53:59")
    @invoiceC1 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-03 14:53:59")
    @invoiceC2 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-04 14:53:59")
    @invoiceC3 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-04 14:53:59")
    @invoiceE1 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-05 14:53:59")
    @invoiceE2 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-06 14:53:59")
    @invoiceE3 = @customer1.invoices.create!(status: "Completed", created_at: "2012-03-06 14:53:59")

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

    visit admin_merchants_path
    expect(page).to have_content("Top selling date for merchantA was Wednesday, March 28, 2012")
    expect(page).to have_content("Top selling date for merchantB was Friday, March 30, 2012")
    expect(page).to have_content("Top selling date for merchantD was Friday, March 2, 2012")
    expect(page).to have_content("Top selling date for merchantC was Sunday, March 4, 2012")
    expect(page).to have_content("Top selling date for merchantE was Tuesday, March 6, 2012")
  end
end
