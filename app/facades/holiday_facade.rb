class HolidayFacade

  def self.next_three_holidays
    data = HolidayService.get_next_holidays
    holidays = []
    data.map do |holiday|
      holidays << Holiday.new(holiday)
    end
    holidays[0..2]
  end
end
