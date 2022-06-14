class HolidayFacade

  def self.next_three_holidays
    connection = Faraday.new(url: 'https://date.nager.at/api/v3/')
    response = connection.get('NextPublicHolidays/us')
    data = JSON.parse(response.body, symbolize_names: true)

    holidays = []
    data.map do |holiday|
      holidays << Holiday.new(holiday)
    end
    holidays[0..2]
  end
end
