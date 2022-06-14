class MerchantInvoicesController < ApplicationController
  before_action :find_merchant

  def index
  end

  def show
    @invoice = Invoice.find(params[:invoice_id])
  end

  def update
    invoice_item = InvoiceItem.find(params[:invoice_item_id])
    invoice_item.update_attributes(status: params[:status])
    redirect_to "/merchants/#{params[:merchant_id]}/invoices/#{params[:invoice_id]}"
  end
end
