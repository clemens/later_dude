begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = "later_dude"
    s.summary     = "Small calendar helper plugin for Rails with i18n support"
    s.email       = "clemens@railway.at"
    s.homepage    = "http://github.com/clemens/later_dude"
    s.description = "LaterDude is a small calendar helper plugin for Rails with i18n support."
    s.authors     = ["Clemens Kofler"]
    s.files       =  FileList["CHANGELOG",
                              "init.rb",
                              "lib/**/*.rb",
                              "MIT-LICENSE",
                              "Rakefile",
                              "README",
                              "tasks/**/*.rb",
                              "VERSION"]
    s.test_files  = FileList["test/**/*.rb"]
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end