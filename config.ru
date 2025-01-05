#
  Dir.chdir(File.dirname(__FILE__))

  require_relative './lib/site.rb'
  require_relative './config/site.rb'

#
  site = Site.default

#
  ENV['HOST'] ||= '0.0.0.0'
  ENV['PORT'] ||= '4242'

  freeze_app

  run(site.server)
