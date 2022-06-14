class BulkDiscountsController < ApplicationController
  before_action :find_merchant

  def index
    @holidays = HolidayFacade.next_three_holidays
  end

  def show
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
  end

  def create
    bulk_discount = @merchant.bulk_discounts.new(bulk_discount_params)
    if bulk_discount.save
      redirect_to "/merchants/#{@merchant.id}/bulk_discounts"
    else
      flash[:alert] = "Information invalid, please try again"
      redirect_to "/merchants/#{@merchant.id}/bulk_discounts/new"
    end
  end

  def edit
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
    @bulk_discount = BulkDiscount.find(params[:id])
    @bulk_discount.update!(bulk_discount_params)
    redirect_to "/merchants/#{@merchant.id}/bulk_discounts/#{@bulk_discount.id}"
  end

  def destroy
    BulkDiscount.find(params[:id]).destroy
    redirect_to "/merchants/#{@merchant.id}/bulk_discounts"
  end

  private
    def bulk_discount_params
      params.permit(:name, :percentage, :quantity_threshold)
    end
end
