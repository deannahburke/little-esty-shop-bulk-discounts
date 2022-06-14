require 'rails_helper'

RSpec.describe Holiday do
  it 'exists with attributes' do
    holiday = Holiday.new({date: '2022-06-20', name: 'Juneteenth'})

    expect(holiday).to be_a(Holiday)
    expect(holiday.name).to eq("Juneteenth")
    expect(holiday.date).to eq("2022-06-20")
  end
end
