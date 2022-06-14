require 'rails_helper'

RSpec.describe Item, type: :model do
  before :each do
    @merchant1 = Merchant.create!(name: 'Merchant1')
    @merchant2 = Merchant.create!(name: 'Merchant2')
    @item1 = @merchant1.items.create!(name: 'Item1', description: 'Description1', unit_price: 111, status: 0)
    @item11 = @merchant1.items.create!(name: 'Item11', description: 'Description11', unit_price: 1111,status: 1)
    @item2 = @merchant2.items.create!(name: 'Item2', description: 'Description2', unit_price: 222, status: 0)

    visit "/merchants/#{@merchant1.id}/items"
  end

  describe 'Merchant items index page content' do
    it 'shows all items for the merchant' do
      expect(page).to have_content("Item1")
      expect(page).to have_content("Item11")
      expect(page).to_not have_content("Item2")
    end
  end

  describe "instance variable" do
    it "change the status of the item" do
      @merchant1 = Merchant.create!(name: 'Merchant1')
      @item1 = @merchant1.items.create!(name: 'Item1', description: 'Description1', unit_price: 111)
      visit "/merchants/#{@merchant1.id}/items"

      within("#status-#{@item1.id}") do
        expect(page).to have_content("Status: enabled")
      end

      click_button "Disable"
      expect(current_path).to eq("/merchants/#{@merchant1.id}/items")

      within("#status-#{@item1.id}") do
        expect(page).to have_content("Status: disabled")
      end

      click_button "Enable"
      expect(current_path).to eq("/merchants/#{@merchant1.id}/items")

      within("#status-#{@item1.id}") do
        expect(page).to have_content("Status: enabled")
      end
    end
  end

  describe "Index Page Content" do
    it "items are placed into the section, enabled or disabled, that matches their status" do
      item111 = @merchant1.items.create!(name: 'Item111', description: 'Description111', unit_price: 11111, status: 1)
      item1111 = @merchant1.items.create!(name: 'Item1111', description: 'Description1111', unit_price: 111111, status: 0)

      visit "/merchants/#{@merchant1.id}/items"

      expect(page).to have_content("Enabled Items")
      expect(page).to have_content("Disabled Items")

      within("#enabled_items") do
        expect(page).to have_content("Item1")
        expect(page).to have_content("Item1111")
        expect(page).to_not have_content("Item11 ")
      end

      within("#disabled_items") do
        expect(page).to have_content("Item11")
        expect(page).to have_content("Item111")
        expect(page).to_not have_content("Item1 ")
      end
    end
  end

  describe 'creating a new item' do
    it 'has button to link to a create new item page' do
      expect(page).to have_button("Create Item")

        click_button "Create Item"
      expect(current_path).to eq("/merchants/#{@merchant1.id}/items/new")
    end

    it 'creates a new item after form completed' do
      visit "/merchants/#{@merchant1.id}/items"
        click_on "Create Item"
        fill_in "Name", with: "NewItem"
        fill_in "Description", with: "NewDescription"
        fill_in "Unit Price", with: "1234"
        click_on "Submit"
      expect(current_path).to eq("/merchants/#{@merchant1.id}/items")
        within("#enabled_items") do
          expect(page).to have_content("NewItem")
        end
    end
  end

  describe "top 5 items" do
    it 'lists the top 5 items by revenue' do
      @merchant1 = Merchant.create!(name: 'Merchant1')
      @itemA = @merchant1.items.create!(name: 'itemA', description: 'Description1', unit_price: 222, status: 0)
      @itemB = @merchant1.items.create!(name: 'itemB', description: 'Descriptions', unit_price: 222,status: 0)
      @itemD = @merchant1.items.create!(name: 'itemD', description: 'Descriptive', unit_price: 222, status: 0)
      @itemC = @merchant1.items.create!(name: 'itemC', description: 'Descriptionless', unit_price: 222, status: 0)
      @itemF = @merchant1.items.create!(name: 'itemF', description: 'Descriptionulous', unit_price: 222, status: 0)
      @itemZ = @merchant1.items.create!(name: 'itemZ', description: 'DescriptionZ', unit_price: 222, status: 0)
      @itemX = @merchant1.items.create!(name: 'itemX', description: 'Descriptionx', unit_price: 2222, status: 0)
      @customer1 = Customer.create!(first_name: "Cuss", last_name: "Tomer")
      @invoiceA = @customer1.invoices.create!(status: "completed")
      @invoiceB = @customer1.invoices.create!(status: "completed")
      @invoiceD = @customer1.invoices.create!(status: "completed")
      @invoiceC = @customer1.invoices.create!(status: "completed")
      @invoiceF = @customer1.invoices.create!(status: "completed")
      @invoiceZ = @customer1.invoices.create!(status: "completed")
      @invoiceX = @customer1.invoices.create!(status: "completed")
      @transaction1 = @invoiceA.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success")
      @transaction2 = @invoiceB.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction3 = @invoiceD.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction4 = @invoiceC.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction5 = @invoiceF.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction6 = @invoiceZ.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction7 = @invoiceX.transactions.create!(credit_card_number: "12345678912134567", credit_card_expiration_date: "1234", result: "failed" )
      @invoice_itemA = @invoiceA.invoice_items.create!(quantity: 1, unit_price: 1000, item_id: @itemA.id, status: "shipped")
      @invoice_itemB = @invoiceB.invoice_items.create!(quantity: 1, unit_price: 800, item_id: @itemB.id, status: "shipped")
      @invoice_itemD = @invoiceD.invoice_items.create!(quantity: 1, unit_price: 600, item_id: @itemD.id, status: "shipped")
      @invoice_itemC = @invoiceC.invoice_items.create!(quantity: 1, unit_price: 400, item_id: @itemC.id, status: "shipped")
      @invoice_itemF = @invoiceF.invoice_items.create!(quantity: 1, unit_price: 200, item_id: @itemF.id, status: "shipped")
      @invoice_itemZ = @invoiceZ.invoice_items.create!(quantity: 1, unit_price: 100, item_id: @itemZ.id, status: "shipped")
      @invoice_itemX = @invoiceX.invoice_items.create!(quantity: 1, unit_price: 1200, item_id: @itemX.id, status: "shipped")
      visit "merchants/#{@merchant1.id}/items"

      within("#top5items") do
        expect("itemA").to appear_before("itemB")
        expect("itemB").to appear_before("itemD")
        expect("itemD").to appear_before("itemC")
        expect("itemC").to appear_before("itemF")
        expect(page).to_not have_content("itemZ") #6th highest total revenue
        expect(page).to_not have_content("itemX") #transactions result not success
      end
    end

    it "shows the top sales date for each of the top 5 items" do

      @merchant1 = Merchant.create!(name: 'Merchant1')
      @customer1 = Customer.create!(first_name: "Cuss", last_name: "Tomer")
      @itemA = @merchant1.items.create!(name: 'itemA', description: 'Description1', unit_price: 222, status: 0)
      @itemB = @merchant1.items.create!(name: 'itemB', description: 'Descriptions', unit_price: 222,status: 0)
      @itemD = @merchant1.items.create!(name: 'itemD', description: 'Descriptive', unit_price: 222, status: 0)
      @itemC = @merchant1.items.create!(name: 'itemC', description: 'Descriptionless', unit_price: 222, status: 0)
      @itemF = @merchant1.items.create!(name: 'itemF', description: 'Descriptionulous', unit_price: 222, status: 0)

      @invoiceA = @customer1.invoices.create!(status: "completed", created_at: "2012-03-15 18:00:00 UTC")
      @invoiceB = @customer1.invoices.create!(status: "completed", created_at: "2012-03-16 18:00:00 UTC")
      @invoiceD = @customer1.invoices.create!(status: "completed", created_at: "2012-03-17 18:00:00 UTC")
      @invoiceC = @customer1.invoices.create!(status: "completed", created_at: "2012-03-18 18:00:00 UTC")
      @invoiceF = @customer1.invoices.create!(status: "completed", created_at: "2012-03-19 18:00:00 UTC")
      @invoiceBB = @customer1.invoices.create!(status: "completed", created_at: "2012-03-15 18:00:00 UTC")
      @invoiceAA = @customer1.invoices.create!(status: "completed", created_at: "2012-03-16 18:00:00 UTC")
      @invoiceCC = @customer1.invoices.create!(status: "completed", created_at: "2012-03-17 18:00:00 UTC")
      @invoiceFF = @customer1.invoices.create!(status: "completed", created_at: "2012-03-18 18:00:00 UTC")
      @invoiceDD = @customer1.invoices.create!(status: "completed", created_at: "2012-03-18 18:00:00 UTC")

      @transaction1 = @invoiceA.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success")
      @transaction2 = @invoiceB.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction3 = @invoiceD.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction4 = @invoiceC.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction5 = @invoiceF.transactions.create!(credit_card_number: "1234567891234567", credit_card_expiration_date: "1234", result: "success" )
      @transaction6= @invoiceAA.transactions.create!(credit_card_number: "12345678912134567", credit_card_expiration_date: "1234", result: "success" )
      @transaction7= @invoiceBB.transactions.create!(credit_card_number: "12345678912134567", credit_card_expiration_date: "1234", result: "success" )
      @transaction8= @invoiceDD.transactions.create!(credit_card_number: "12345678912134567", credit_card_expiration_date: "1234", result: "success" )
      @transaction9= @invoiceCC.transactions.create!(credit_card_number: "12345678912134567", credit_card_expiration_date: "1234", result: "success" )
      @transaction10 = @invoiceFF.transactions.create!(credit_card_number: "12345678912134567", credit_card_expiration_date: "1234", result: "success" )
      @invoice_itemA = @invoiceA.invoice_items.create!(quantity: 13, unit_price: 41, item_id: @itemA.id, status: "shipped")
      @invoice_itemB = @invoiceB.invoice_items.create!(quantity: 11, unit_price: 33, item_id: @itemB.id, status: "shipped")
      @invoice_itemD = @invoiceD.invoice_items.create!(quantity: 7, unit_price: 5, item_id: @itemD.id, status: "shipped")
      @invoice_itemC = @invoiceC.invoice_items.create!(quantity: 5, unit_price: 7, item_id: @itemC.id, status: "shipped")
      @invoice_itemF = @invoiceF.invoice_items.create!(quantity: 3, unit_price: 13, item_id: @itemF.id, status: "shipped")
      @invoice_itemBB= @invoiceBB.invoice_items.create!(quantity: 17, unit_price: 33, item_id: @itemB.id, status: "shipped")
      @invoice_itemDD= @invoiceDD.invoice_items.create!(quantity: 11, unit_price: 5, item_id: @itemD.id, status: "shipped")
      @invoice_itemCC= @invoiceCC.invoice_items.create!(quantity: 23, unit_price: 7, item_id: @itemC.id, status: "shipped")
      @invoice_itemFF= @invoiceFF.invoice_items.create!(quantity: 17, unit_price: 13, item_id: @itemF.id, status: "shipped")
      @invoice_itemAA= @invoiceAA.invoice_items.create!(quantity: 19, unit_price: 41, item_id: @itemA.id, status: "shipped")
      visit "/merchants/#{@merchant1.id}/items"

        expect(page).to have_content("Top selling date for itemA was 03-16-2012")
        expect(page).to have_content("Top selling date for itemB was 03-15-2012")
        expect(page).to have_content("Top selling date for itemC was 03-17-2012")
        expect(page).to have_content("Top selling date for itemD was 03-18-2012")
        expect(page).to have_content("Top selling date for itemF was 03-18-2012")

    end
  end
end
