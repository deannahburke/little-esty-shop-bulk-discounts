class BulkDiscountsController < ApplicationController

  def index
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discounts = @merchant.bulk_discounts
  end

  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    bulk_discount = @merchant.bulk_discounts.new(bulk_discount_params)
    if bulk_discount.save
      redirect_to "/merchants/#{@merchant.id}/bulk_discounts"
    else
      flash[:alert] = "Information invalid, please try again"
      redirect_to "/merchants/#{@merchant.id}/bulk_discounts/new"
    end
  end

  def destroy
    # require "pry";binding.pry
    merchant = Merchant.find(params[:merchant_id])
    BulkDiscount.find(params[:id]).destroy
    redirect_to "/merchants/#{merchant.id}/bulk_discounts"
  end


  private
    def bulk_discount_params
      params.permit(:name, :percentage, :quantity_threshold)
    end
end
