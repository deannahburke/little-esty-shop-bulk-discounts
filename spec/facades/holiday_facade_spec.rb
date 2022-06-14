require 'rails_helper'

RSpec.describe HolidayFacade do
  it 'returns holiday objects' do
    holidays = HolidayService.get_next_holidays
    expect(holidays).to be_an Array
    expect(HolidayFacade.next_three_holidays.count).to eq(3)
  end
end
