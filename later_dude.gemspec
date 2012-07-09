Gem::Specification.new do |s|
  s.name = %q{later_dude}
  s.version = "0.3.1"

  s.authors = ["Clemens Kofler"]
  s.description = %q{LaterDude is a small calendar helper plugin for Rails with i18n support.}
  s.summary = %q{Small calendar helper plugin for Rails with i18n support}
  s.email = %q{clemens@railway.at}
  s.homepage = %q{http://github.com/clemens/later_dude}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "CHANGELOG",
    "MIT-LICENSE",
    "README.md",
    "Rakefile",
    "init.rb",
    "lib/later_dude.rb",
    "lib/later_dude/calendar.rb",
    "lib/later_dude/calendar_helper.rb",
    "lib/later_dude/rails2_compat.rb",
    "lib/later_dude/railtie.rb"
  ]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.test_files = [
    "test/calendar_helper_test.rb",
    "test/calendar_test.rb",
    "test/test_helper.rb"
  ]

  s.add_dependency 'rails', '>= 2.3'
  s.add_development_dependency 'mocha'
end
