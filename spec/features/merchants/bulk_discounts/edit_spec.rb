require 'rails_helper'

RSpec.describe 'the bulk discounts edit', type: :feature do
  before(:each)do
    @billman = Merchant.create!(name: "Billman")

    @bracelet = @billman.items.create!(name: "Bracelet", description: "Shiny", unit_price: 1001)
    @mood = @billman.items.create!(name: "Mood Ring", description: "Moody", unit_price: 2002)
    @necklace = @billman.items.create!(name: "Necklace", description: "Sparkly", unit_price: 3045)

    @brenda = Customer.create!(first_name: "Brenda", last_name: "Bhoddavista")

    @invoice1 = @brenda.invoices.create!(status: "In Progress")
    @invoice2 = @brenda.invoices.create!(status: "Completed")
    @invoice3 = @brenda.invoices.create!(status: "Completed")
    @invoice4= @brenda.invoices.create!(status: "Completed")

    InvoiceItem.create!(item_id: @bracelet.id, invoice_id: @invoice1.id, quantity: 6, unit_price: 1001, status: "Pending")
    InvoiceItem.create!(item_id: @mood.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 1001, status: "Pending")
    InvoiceItem.create!(item_id: @mood.id, invoice_id: @invoice3.id, quantity: 10, unit_price: 1001, status: "Pending")
    InvoiceItem.create!(item_id: @necklace.id, invoice_id: @invoice4.id, quantity: 12, unit_price: 1001, status: "Pending")

    @discount1 = @billman.bulk_discounts.create!(name: "Bulk10", percentage: 20, quantity_threshold: 10)
    @discount2 = @billman.bulk_discounts.create!(name: "Bulk15", percentage: 30, quantity_threshold: 15)
  end

  it 'links to edit a discount' do
    visit "/merchants/#{@billman.id}/bulk_discounts/#{@discount1.id}"

    click_link("Edit #{@discount1.name}")

    expect(current_path).to eq("/merchants/#{@billman.id}/bulk_discounts/#{@discount1.id}/edit")
  end

  it 'can edit a discount' do
    visit "/merchants/#{@billman.id}/bulk_discounts/#{@discount1.id}/edit"

    fill_in('Name', with: 'Bulk25')
    fill_in('Percentage', with: 25)
    fill_in('Quantity Threshold', with: 25)
    click_button('Edit Discount')

    expect(current_path).to eq("/merchants/#{@billman.id}/bulk_discounts/#{@discount1.id}")
    expect(page).to have_content("Bulk25")
    expect(page).to have_content(25)
    expect(page).to have_content(25)
    expect(page).to_not have_content("Bulk10")
    expect(page).to_not have_content(20)
    expect(page).to_not have_content(10)
  end
end
