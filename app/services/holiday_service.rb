class HolidayService

  def self.get_next_holidays
    connection = Faraday.new(url: 'https://date.nager.at/api/v3/')
    response = connection.get('NextPublicHolidays/us')
    data = JSON.parse(response.body, symbolize_names: true)
  end 

end
