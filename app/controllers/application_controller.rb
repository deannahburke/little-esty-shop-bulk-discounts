class ApplicationController < ActionController::Base
  def welcome
  end

  private

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
