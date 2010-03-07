module LaterDude
  module CalendarHelper
    def calendar_for(year, month, options={}, &block)
      Calendar.new(year, month, options, &block).to_html
    end
  end
end
