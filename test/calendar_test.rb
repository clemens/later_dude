require 'test_helper'

I18n.load_path += Dir[File.expand_path('fixtures/locales', File.dirname(__FILE__)) + '/*.yml']

# TODO: figure out why I have to reference Calendar via its module ...
class CalendarTest < ActiveSupport::TestCase
  # some constants for increased readability
  FULL_DAY_NAMES   = I18n.translate(:'date.day_names')
  ABBR_DAY_NAMES   = I18n.translate(:'date.abbr_day_names')
  FULL_MONTH_NAMES = I18n.translate(:'date.month_names')
  ABBR_MONTH_NAMES = I18n.translate(:'date.abbr_month_names')

  setup do
    I18n.locale = 'en'
  end

  test "has default options" do
    # TODO improve this so that every call gets a fresh copy of the default options
    default_calendar_options = LaterDude::Calendar.send(:default_calendar_options)

    assert_kind_of Hash, default_calendar_options

    assert_equal "calendar", default_calendar_options[:calendar_class]

    [:hide_day_names, :hide_month_name, :use_full_day_names].each do |key|
      assert !default_calendar_options[key]
    end

    # default date format for header is to show the full month name if no translation is set in locale
    assert_equal "%B", default_calendar_options[:current_month]

    # next and previous month aren't shown by default
    assert !default_calendar_options[:next_month]
    assert !default_calendar_options[:previous_month]
    assert !default_calendar_options[:next_and_previous_month]

    # default first day of week is Sunday (= 0) if no translation is set in locale
    assert_equal 0, default_calendar_options[:first_day_of_week]

    I18n.locale = 'de'
    # with default first day of week set in locale
    assert_equal 1, (LaterDude::Calendar.send(:default_calendar_options)[:first_day_of_week]) # have to do this so that we don't use the cached version

    # with default date format set in locale
    assert_equal "%B %Y", (LaterDude::Calendar.send(:default_calendar_options)[:current_month])
  end

  # options
  test "uses full day names" do
    assert_equal FULL_DAY_NAMES, LaterDude::Calendar.new(2009, 1, :use_full_day_names => true).send(:day_names)
  end

  test "uses abbreviated day names" do
    assert_equal ABBR_DAY_NAMES, LaterDude::Calendar.new(2009, 1).send(:day_names)
    assert_equal ABBR_DAY_NAMES, LaterDude::Calendar.new(2009, 1, :use_full_day_names => false).send(:day_names)
  end

  test "doesn't show day names" do
    assert_nil LaterDude::Calendar.new(2009, 1, :hide_day_names => true).send(:show_day_names)
  end

  # TODO I think this isn't needed anymore due to the new :header_date_format option
  test "doesn't show month names" do
    assert_nil LaterDude::Calendar.new(2009, 1, :hide_month_name => true).send(:show_month_names)
  end

  # links/texts for next, previous and current month
  test "uses next month for a string" do
    assert_match %r(&raquo;), LaterDude::Calendar.new(2009, 1, :next_month => "&raquo;").send(:next_month)
  end

  test "uses next month for a strftime string" do
    assert_match %r(Feb), LaterDude::Calendar.new(2009, 1, :next_month => "%b").send(:next_month)
  end

  test "uses next month for proc" do
    assert_match %r(<a href="/events/2009/2">&raquo;</a>), LaterDude::Calendar.new(2009, 1, :next_month => lambda { |date| %(<a href="/events/#{date.year}/#{date.month}">&raquo;</a>) }).send(:next_month)
  end

  test "uses next month for array if first value is a string and second is a proc" do
    assert_match %r(<a href="/events/2009/2">&raquo;</a>), LaterDude::Calendar.new(2009, 1, :next_month => ["&raquo;", lambda { |date| "/events/#{date.year}/#{date.month}" }]).send(:next_month)
  end

  test "uses next month for array if first value is a strftime string and second is a proc" do
    assert_match %r(<a href="/events/2009/2">Feb</a>), LaterDude::Calendar.new(2009, 1, :next_month => ["%b", lambda { |date| "/events/#{date.year}/#{date.month}" }]).send(:next_month)
  end

  test "uses previous month for a string" do
    assert_match %r(&laquo;), LaterDude::Calendar.new(2009, 1, :previous_month => "&laquo;").send(:previous_month)
  end

  test "uses previous month for a strftime string" do
    assert_match %r(Dec), LaterDude::Calendar.new(2009, 1, :previous_month => "%b").send(:previous_month)
  end

  test "uses previous month for proc" do
    assert_match %r(<a href="/events/2008/12">&laquo;</a>), LaterDude::Calendar.new(2009, 1, :previous_month => lambda { |date| %(<a href="/events/#{date.year}/#{date.month}">&laquo;</a>) }).send(:previous_month)
  end

  test "uses previous month for array if first value is a string and second is a proc" do
    assert_match %r(<a href="/events/2008/12">&laquo;</a>), LaterDude::Calendar.new(2009, 1, :previous_month => ["&laquo;", lambda { |date| "/events/#{date.year}/#{date.month}" }]).send(:previous_month)
  end

  test "uses previous month for array if first value is a strftime string and second is a proc" do
    assert_match %r(<a href="/events/2008/12">Dec</a>), LaterDude::Calendar.new(2009, 1, :previous_month => ["%b", lambda { |date| "/events/#{date.year}/#{date.month}" }]).send(:previous_month)
  end

  test "uses next and previous month for array if first value is a strftime string and second is a proc" do
    calendar = LaterDude::Calendar.new(2009, 1, :next_and_previous_month => ["%b", lambda { |date| "/events/#{date.year}/#{date.month}" }])
    assert_match %r(<a href="/events/2008/12">Dec</a>), calendar.send(:previous_month)
    assert_match %r(<a href="/events/2009/2">Feb</a>), calendar.send(:next_month)
  end

  test "uses next/previous month options rather than combined option if both are given" do
    calendar = LaterDude::Calendar.new(2009, 1, :next_month => "&raquo;", :previous_month => "&laquo;", :next_and_previous_month => ["%b", lambda { |date| "/events/#{date.year}/#{date.month}" }])
    assert_match %r(&laquo;), calendar.send(:previous_month)
    assert_match %r(&raquo;), calendar.send(:next_month)
  end

  test "uses current month for a string" do
    assert_match %r(Current), LaterDude::Calendar.new(2009, 1, :current_month => "Current").send(:current_month)
  end

  test "uses current month for a strftime string" do
    assert_match %r(Jan), LaterDude::Calendar.new(2009, 1, :current_month => "%b").send(:current_month)
  end

  test "uses current month for proc" do
    assert_match %r(<a href="/events/2009/1">Current</a>), LaterDude::Calendar.new(2009, 1, :current_month => lambda { |date| %(<a href="/events/#{date.year}/#{date.month}">Current</a>) }).send(:current_month)
  end

  test "uses current month for array if first value is a string and second is a proc" do
    assert_match %r(<a href="/events/2009/1">Current</a>), LaterDude::Calendar.new(2009, 1, :current_month => ["Current", lambda { |date| "/events/#{date.year}/#{date.month}" }]).send(:current_month)
  end

  test "uses current month for array if first value is a strftime string and second is a proc" do
    assert_match %r(<a href="/events/2009/1">Jan</a>), LaterDude::Calendar.new(2009, 1, :current_month => ["%b", lambda { |date| "/events/#{date.year}/#{date.month}" }]).send(:current_month)
  end

  # helper methods
  test "shows whether a given day is on a weekend or not" do
    # first week of March 2010 starts on Monday => :-)
    (Date.civil(2010, 3, 1)..Date.civil(2010, 3, 5)).each do |day|
      assert !LaterDude::Calendar.weekend?(day)
    end

    [Date.civil(2010, 3, 6), Date.civil(2010, 3, 7)].each do |day|
      assert LaterDude::Calendar.weekend?(day)
    end
  end

  test "includes day name abbreviation" do
    assert_equal %q(<abbr title="Sunday">Sun</abbr>), LaterDude::Calendar.new(2009, 1, :use_full_day_names => false).send(:include_day_abbreviation, "Sun")
  end

  test "doesn't include day name abbreviation" do
    assert_equal "Sunday", LaterDude::Calendar.new(2009, 1, :use_full_day_names => true).send(:include_day_abbreviation, "Sunday")
  end

  test "shows index of first and last day of week" do
    assert_equal 0, LaterDude::Calendar.new(2009, 1).send(:first_day_of_week)
    assert_equal 6, LaterDude::Calendar.new(2009, 1).send(:last_day_of_week)

    assert_equal 1, LaterDude::Calendar.new(2009, 1, :first_day_of_week => 1).send(:first_day_of_week)
    assert_equal 0, LaterDude::Calendar.new(2009, 1, :first_day_of_week => 1).send(:last_day_of_week)
  end

  test "applies first day of week accordingly" do
    assert_equal %w(Mon Tue Wed Thu Fri Sat Sun), LaterDude::Calendar.new(2009, 1, :first_day_of_week => 1).send(:apply_first_day_of_week, ABBR_DAY_NAMES)
  end

  test "returns the first day of the week for a given date" do
    day = Date.civil(2009, 1, 4) # first Sunday in 2009

    assert_equal Date.civil(2009, 1, 4),   LaterDude::Calendar.new(2009, 1, :first_day_of_week => 0).send(:beginning_of_week, day)
    assert_equal Date.civil(2008, 12, 29), LaterDude::Calendar.new(2009, 1, :first_day_of_week => 1).send(:beginning_of_week, day)
    assert_equal Date.civil(2008, 12, 30), LaterDude::Calendar.new(2009, 1, :first_day_of_week => 2).send(:beginning_of_week, day)
    assert_equal Date.civil(2008, 12, 31), LaterDude::Calendar.new(2009, 1, :first_day_of_week => 3).send(:beginning_of_week, day)
    assert_equal Date.civil(2009, 1, 1),   LaterDude::Calendar.new(2009, 1, :first_day_of_week => 4).send(:beginning_of_week, day)
    assert_equal Date.civil(2009, 1, 2),   LaterDude::Calendar.new(2009, 1, :first_day_of_week => 5).send(:beginning_of_week, day)
    assert_equal Date.civil(2009, 1, 3),   LaterDude::Calendar.new(2009, 1, :first_day_of_week => 6).send(:beginning_of_week, day)
  end

  # TODO: may consider to mock some of the behavior so I don't have to use concrete months that fit for a test
  test "shows previous month if first day of month isn't the first day of a week" do
    assert_not_nil LaterDude::Calendar.new(2009, 4).send(:show_previous_month) # April 1st is a Wednesday
  end

  test "shows following month if last day of month isn't the last day of a week" do
    assert_not_nil LaterDude::Calendar.new(2009, 4).send(:show_following_month) # April 30th is a Thursday
  end

  test "shouldn't show previous month if first day of month is the first day of a week" do
    assert_nil LaterDude::Calendar.new(2009, 2).send(:show_previous_month) # February 1st is a Sunday
  end

  test "shouldn't show following month if last day of month is the last day of a week" do
    assert_nil LaterDude::Calendar.new(2009, 2).send(:show_following_month) # February 28th is a Saturday
  end

  test "highlights current day (= today)" do
    Date.stubs(:current).then.returns(Date.civil(2009, 1, 14))
    assert_match %r(<td class="([^\"]*)today([^\"]*)">14</td>), LaterDude::Calendar.new(2009, 1).to_html
  end

  test "shows special days as designated by a block" do
    # all even days should be linked
    special_days_proc = lambda do |day|
      if day.day.even?
        [%(<a href="/calendar/#{day.year}/#{day.month}/#{day.day}">#{day.day}</a>), { :class => 'specialDay' }]
      else
        day.day
      end
    end

    calendar_html = LaterDude::Calendar.new(2009, 1, &special_days_proc).to_html

    (Date.civil(2009, 1, 1)..Date.civil(2009, 1, -1)).each do |day|
      if day.day.even?
        assert_match %r(<td class="day([^\"]*)specialDay"><a href="/calendar/#{day.year}/#{day.month}/#{day.day}">#{day.day}</a></td>), calendar_html
      else
        assert_match %r(<td class="day([^\"]*)">#{day.day}</td>), calendar_html
        assert_no_match %r(<td class="day([^\"]*)specialDay"><a href="/calendar/#{day.year}/#{day.month}/#{day.day}">#{day.day}</a></td>), calendar_html
      end
    end
  end

  test "yields days of surrounding months :yield_surrounding_days is set to true" do
    # make it bold
    special_days_proc = lambda { |day| "<b>#{day.day}</b>" }

    calendar_html = LaterDude::Calendar.new(2009, 4, { :yield_surrounding_days => true }, &special_days_proc).to_html

    # start of first week: 29 March 2009
    # end of last week: 2 May 2009
    surrounding_days = [Date.civil(2009, 3, 29), Date.civil(2009, 3, 30), Date.civil(2009, 3, 31), Date.civil(2009, 5, 1), Date.civil(2009, 5, 2)]
    surrounding_days.each do |day|
      assert_match %r(<td class="day([^\"]*)otherMonth([^\"]*)"><b>#{day.day}</b></td>), calendar_html
    end
  end

  test "yields days of surrounding months :yield_surrounding_days isn't set to true" do
    # make it bold
    special_days_proc = lambda { |day| "<b>#{day.day}</b>" }

    calendar_html  = LaterDude::Calendar.new(2009, 4, &special_days_proc).to_html
    calendar_html2 = LaterDude::Calendar.new(2009, 4, { :yield_surrounding_days => false }, &special_days_proc).to_html

    # start of first week: 29 March 2009
    # end of last week: 2 May 2009
    surrounding_days = [Date.civil(2009, 3, 29), Date.civil(2009, 3, 30), Date.civil(2009, 3, 31), Date.civil(2009, 5, 1), Date.civil(2009, 5, 2)]
    surrounding_days.each do |day|
      assert_no_match %r(<td class="day([^\"]*)otherMonth([^\"]*)"><b>#{day.day}</b></td>), calendar_html
      assert_no_match %r(<td class="day([^\"]*)otherMonth([^\"]*)"><b>#{day.day}</b></td>), calendar_html2
    end
  end

  # TODO: Should I do "real" output testing despite the good coverage of output-related methods? Testing HTML is tedious ...
end
