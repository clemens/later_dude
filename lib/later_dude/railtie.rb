require 'later_dude/calendar_helper'

module LaterDude
  class Railtie < Rails::Railtie
    initializer "later_dude.view_helpers" do
      ActionView::Base.send :include, CalendarHelper
    end
  end
end