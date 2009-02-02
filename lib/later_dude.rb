require 'i18n'

module LaterDude
  module CalendarHelper
    def calendar_for(year, month, options={}, &block)
      Calendar.new(year, month, options, &block).to_html
    end
  end

  # TODO: Maybe make output prettier?
  class Calendar
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    def initialize(year, month, options={}, &block)
      @year, @month = year, month
      @options = options.symbolize_keys.reverse_merge(Calendar.default_calendar_options)

      # next_month and previous_month take precedence over next_and_previous_month
      @options[:next_month]     ||= @options[:next_and_previous_month]
      @options[:previous_month] ||= @options[:next_and_previous_month]

      @days = Date.civil(@year, @month, 1)..Date.civil(@year, @month, -1)
      @block = block
    end

    def to_html
      <<-EOF
        <table class="#{@options[:calendar_class]}">
          <thead>
            #{show_month_names}
            #{show_day_names}
          </thead>
          <tbody>
            #{show_days}
          </tbody>
        </table>
      EOF
    end

    private
    def show_days
      "<tr>#{show_previous_month}#{show_current_month}#{show_following_month}</tr>"
    end

    def show_previous_month
      return if @days.first.wday == first_day_of_week # don't display anything if the first day is the first day of a week

      returning "" do |output|
        beginning_of_week(@days.first).upto(@days.first - 1) { |d| output << show_day(d) }
      end
    end

    def show_current_month
      returning "" do |output|
        @days.first.upto(@days.last) { |d| output << show_day(d) }
      end
    end

    def show_following_month
      return if @days.last.wday == last_day_of_week # don't display anything if the last day is the last day of a week

      returning "" do |output|
        (@days.last + 1).upto(beginning_of_week(@days.last + 1.week) - 1) { |d| output << show_day(d) }
      end
    end

    def show_day(day)
      options = { :class => "day" }
      options[:class] << " otherMonth" if day.month != @days.first.month
      options[:class] << " weekend" if Calendar.weekend?(day)
      options[:class] << " today" if day.today?

      # block is only called for current month
      if @block && day.month == @days.first.month
        content, options_from_block = Array(@block.call(day))

        # passing options is optional
        if options_from_block.is_a?(Hash)
          options[:class] << " #{options_from_block.delete(:class)}" if options_from_block[:class]
          options.merge!(options_from_block)
        end
      else
        content = day.day
      end

      returning content_tag(:td, content, options) do |output|
        if day < @days.last && day.wday == last_day_of_week # opening and closing tag for the first and last week are included in #show_days
          output << "</tr><tr>" # close table row at the end of a week and start a new one
        end
      end
    end

    def beginning_of_week(day)
      diff = day.wday - first_day_of_week
      diff += 7 if first_day_of_week > day.wday # hackish ;-)
      day - diff
    end

    def show_month_names
      return if @options[:hide_month_name]

      %(<tr>
        #{previous_month}#{current_month}#{next_month}
      </tr>)
    end

    # @options[:previous_month] can either be a single value or an array containing two values. For a single value, the
    # value can either be a strftime compatible string or a proc.
    # For an array, the first value is considered to be a strftime compatible string and the second is considered to be
    # a proc. If the second value is not a proc then it will be ignored.
    def previous_month
      return unless previous_month = @options[:previous_month]

      m = (@days.first - 1.month)

      returning '<th colspan="2">' do |output|
        output << if previous_month.kind_of?(Array) && previous_month.size == 2
          text = I18n.localize(m, :format => previous_month.first.to_s)
          previous_month.last.respond_to?(:call) ? link_to(text, previous_month.last.call(m)) : text
        else
          previous_month.respond_to?(:call) ? previous_month.call(m) : I18n.localize(m, :format => previous_month.to_s)
        end
        output << '</th>'
      end
    end

    # see previous_month
    def next_month
      return unless next_month = @options[:next_month]

      m = (@days.first + 1.month)

      returning '<th colspan="2">' do |output|
        output << if next_month.kind_of?(Array) && next_month.size == 2
          text = I18n.localize(m, :format => next_month.first.to_s)
          next_month.last.respond_to?(:call) ? link_to(text, next_month.last.call(m)) : text
        else
          next_month.respond_to?(:call) ? next_month.call(m) : I18n.localize(m, :format => next_month.to_s)
        end
        output << '</th>'
      end
    end

    # see previous_month and next_month
    def current_month
      current_month = @options[:current_month]
      m = @days.first

      colspan = @options[:previous_month] || @options[:next_month] ? 3 : 7 # span across all 7 days if previous and next month aren't shown

      returning %(<th colspan="#{colspan}">) do |output|
        output << if current_month.kind_of?(Array) && current_month.size == 2
          text = I18n.localize(m, :format => current_month.first.to_s)
          current_month.last.respond_to?(:call) ? link_to(text, current_month.last.call(m)) : text
        else
          current_month.respond_to?(:call) ? current_month.call(m) : I18n.localize(m, :format => current_month.to_s)
        end
        output << '</th>'
      end
    end

    def day_names
      @day_names ||= @options[:use_full_day_names] ? full_day_names : abbreviated_day_names
    end

    def full_day_names
      @full_day_names ||= I18n.translate(:'date.day_names')
    end

    def abbreviated_day_names
      @abbreviated_day_names ||= I18n.translate(:'date.abbr_day_names')
    end

    def show_day_names
      return if @options[:hide_day_names]

      returning "<tr>" do |output|
        apply_first_day_of_week(day_names).each do |day|
          output << %(<th scope="col">#{include_day_abbreviation(day)}</th>)
        end
        output << "</tr>"
      end
    end

    # => <abbr title="Sunday">Sun</abbr>
    def include_day_abbreviation(day)
      return day if @options[:use_full_day_names]

      %(<abbr title="#{full_day_names[abbreviated_day_names.index(day)]}">#{day}</abbr>)
    end

    def apply_first_day_of_week(day_names)
      names = day_names.dup
      first_day_of_week.times { names.push(names.shift) }
      names
    end

    def first_day_of_week
      @options[:first_day_of_week]
    end

    def last_day_of_week
      @options[:first_day_of_week] > 0 ? @options[:first_day_of_week] - 1 : 6
    end

    class << self
      def weekend?(day)
        [0,6].include?(day.wday) # 0 = Sunday, 6 = Saturday
      end

      def default_calendar_options
        {
          :calendar_class => "calendar",
          :first_day_of_week => I18n.translate(:'date.first_day_of_week', :default => "0").to_i,
          :hide_day_names => false,
          :hide_month_name => false,
          :use_full_day_names => false,
          :current_month => I18n.translate(:'date.formats.calendar_header', :default => "%B"),
          :next_month => false,
          :previous_month => false,
          :next_and_previous_month => false
        }
      end
    end
  end
end